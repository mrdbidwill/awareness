import { Controller } from "@hotwired/stimulus"

// Inline Autocomplete Controller for textarea fields
// Provides genus/species name suggestions while typing in prose
// Inserts selected text at cursor position
// Primary use case: Helping users spell genus/species names correctly in articles and mushroom notes

export default class extends Controller {
  static targets = ["textarea", "dropdown"]
  static values = {
    genusUrl: String,
    speciesUrl: String,
    min: { type: Number, default: 4 }
  }

  connect() {
    this.debounceTimer = null
    this.currentWord = ""
    this.cursorPosition = 0
    this.wordStart = 0
    this.ignoreNextInput = false
  }

  onInput(event) {
    // Skip if this input was triggered by our own text insertion
    if (this.ignoreNextInput) {
      this.ignoreNextInput = false
      return
    }

    clearTimeout(this.debounceTimer)

    const textarea = this.textareaTarget
    this.cursorPosition = textarea.selectionStart
    const text = textarea.value

    // Get word at cursor
    const wordInfo = this.getWordAtCursor(text, this.cursorPosition)
    this.currentWord = wordInfo.word
    this.wordStart = wordInfo.start

    // Check if should trigger autocomplete:
    // 1. Uppercase word >= 4 chars (genus name like "Ganoderma")
    // 2. OR lowercase word >= 4 chars AFTER a capitalized word (species epithet like "sessile" after "Ganoderma")
    const isUppercase = /^[A-Z]/.test(this.currentWord)
    const isLowercaseAfterGenus = /^[a-z]/.test(this.currentWord) && this.hasPrecedingCapitalizedWord(text, this.wordStart)

    if (this.currentWord.length >= this.minValue && (isUppercase || isLowercaseAfterGenus)) {
      this.debounceTimer = setTimeout(() => {
        this.fetchSuggestions(this.currentWord)
      }, 150)
    } else {
      this.hideDropdown()
    }
  }

  hasPrecedingCapitalizedWord(text, currentWordStart) {
    // Look backwards from current word to find previous word
    // Check if it starts with capital letter (likely a genus name)
    let i = currentWordStart - 1

    // Skip whitespace backwards
    while (i >= 0 && /\s/.test(text[i])) {
      i--
    }

    if (i < 0) return false

    // Find start of previous word
    let prevWordEnd = i
    while (i >= 0 && /[a-zA-Z]/.test(text[i])) {
      i--
    }

    const prevWord = text.substring(i + 1, prevWordEnd + 1)
    return prevWord.length > 0 && /^[A-Z]/.test(prevWord)
  }

  getPreviousWord(text, currentWordStart) {
    // Extract the previous word (genus name) for filtering species
    let i = currentWordStart - 1

    // Skip whitespace backwards
    while (i >= 0 && /\s/.test(text[i])) {
      i--
    }

    if (i < 0) return ""

    // Find start of previous word
    let prevWordEnd = i
    while (i >= 0 && /[a-zA-Z]/.test(text[i])) {
      i--
    }

    return text.substring(i + 1, prevWordEnd + 1)
  }

  getWordAtCursor(text, position) {
    // Find word boundaries (letters only, no spaces or punctuation)
    let start = position
    let end = position

    // Move back to start of word
    while (start > 0 && /[a-zA-Z]/.test(text[start - 1])) {
      start--
    }

    // Move forward to end of word
    while (end < text.length && /[a-zA-Z]/.test(text[end])) {
      end++
    }

    return {
      word: text.substring(start, end),
      start: start,
      end: end
    }
  }

  async fetchSuggestions(query) {
    try {
      const textarea = this.textareaTarget
      const text = textarea.value
      const isLowercaseAfterGenus = /^[a-z]/.test(query) && this.hasPrecedingCapitalizedWord(text, this.wordStart)

      // If lowercase word after a capitalized word, search SPECIES first (likely typing species epithet)
      if (isLowercaseAfterGenus) {
        // Extract the previous genus name to filter species by that genus
        const prevGenus = this.getPreviousWord(text, this.wordStart)

        const speciesResponse = await fetch(
          `${this.speciesUrlValue}?q=${encodeURIComponent(query)}&genus_name=${encodeURIComponent(prevGenus)}`,
          { headers: { "Accept": "application/json" } }
        )

        if (speciesResponse.ok) {
          const speciesData = await speciesResponse.json()

          if (speciesData.length > 0) {
            this.renderDropdown(speciesData)
            return
          }
        }

        // No species matches - try genus as fallback
        const genusResponse = await fetch(`${this.genusUrlValue}?q=${encodeURIComponent(query)}`, {
          headers: { "Accept": "application/json" }
        })

        if (genusResponse.ok) {
          const genusData = await genusResponse.json()
          if (genusData.length > 0) {
            this.renderDropdown(genusData)
          } else {
            this.hideDropdown()
          }
        } else {
          this.hideDropdown()
        }
      } else {
        // Uppercase word - search GENUS ONLY (no species fallback)
        // This prevents words like "Still" from matching species names with substring matches
        const genusResponse = await fetch(`${this.genusUrlValue}?q=${encodeURIComponent(query)}`, {
          headers: { "Accept": "application/json" }
        })

        if (genusResponse.ok) {
          const genusData = await genusResponse.json()

          if (genusData.length > 0) {
            this.renderDropdown(genusData)
          } else {
            this.hideDropdown()
          }
        } else {
          this.hideDropdown()
        }
      }
    } catch (error) {
      console.error("Autocomplete error:", error)
      this.hideDropdown()
    }
  }

  renderDropdown(items) {
    this.dropdownTarget.innerHTML = items
      .map(item => `
        <li class="px-4 py-3 hover:bg-blue-500 hover:text-white cursor-pointer border-b border-gray-200 last:border-b-0"
            data-action="click->inline-autocomplete#selectItem"
            data-name="${item.name}">
          <strong class="text-base">${item.name}</strong>
        </li>
      `).join("")

    this.dropdownTarget.classList.remove("hidden")
  }

  selectItem(event) {
    event.preventDefault()
    event.stopPropagation()

    const selectedName = event.currentTarget.dataset.name
    const textarea = this.textareaTarget
    const text = textarea.value

    // Check if we're replacing a species epithet (lowercase after genus)
    // If so, we need to replace BOTH the genus and species words to avoid duplication
    const isLowercaseWord = /^[a-z]/.test(this.currentWord)
    const hasPrevGenus = this.hasPrecedingCapitalizedWord(text, this.wordStart)

    let before, after, replaceStart
    if (isLowercaseWord && hasPrevGenus) {
      // Find start of previous genus word
      const prevGenus = this.getPreviousWord(text, this.wordStart)
      const genusStart = this.wordStart - prevGenus.length - 1 // -1 for space

      replaceStart = genusStart
      before = text.substring(0, genusStart)
      after = text.substring(this.cursorPosition)
    } else {
      // Normal replacement - just replace current word
      replaceStart = this.wordStart
      before = text.substring(0, this.wordStart)
      after = text.substring(this.cursorPosition)
    }

    // Apply <em> tags to complete binomials (contains space like "Ganoderma sessile")
    // This follows scientific naming conventions: binomial names must be italicized
    const isBinomial = selectedName.includes(' ')

    let formattedName, cursorOffset
    if (isBinomial) {
      // Complete binomial - wrap in <em> tags per nomenclature standards
      formattedName = `<em>${selectedName}</em>`
      cursorOffset = selectedName.length + 9 // position AFTER closing </em> tag
    } else {
      // Genus only - no HTML tags, add trailing space
      formattedName = selectedName + ' '
      cursorOffset = selectedName.length + 1
    }

    textarea.value = before + formattedName + after

    // Hide dropdown immediately
    this.hideDropdown()

    // Position cursor after the insertion
    const newPosition = before.length + cursorOffset
    textarea.setSelectionRange(newPosition, newPosition)
    textarea.focus()

    // Set flag to ignore the input event we're about to trigger
    this.ignoreNextInput = true

    // Trigger input event for character count update
    textarea.dispatchEvent(new Event('input', { bubbles: true }))
  }

  hideDropdown() {
    this.dropdownTarget.classList.add("hidden")
    this.dropdownTarget.innerHTML = ""
  }

  onKeydown(event) {
    // Handle keyboard navigation in dropdown
    if (!this.dropdownTarget.classList.contains("hidden")) {
      if (event.key === "Escape") {
        this.hideDropdown()
        event.preventDefault()
      } else if (event.key === "ArrowDown" || event.key === "ArrowUp") {
        // TODO: Add arrow key navigation through dropdown items
        event.preventDefault()
      }
    }
  }
}
