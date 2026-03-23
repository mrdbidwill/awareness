import { Controller } from "@hotwired/stimulus"

// Inline autocomplete for prose-like text fields.
// Matches the working behavior from mrdbid: genus-first suggestions, species
// suggestions when typing a lowercase epithet after a genus.
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

  onInput() {
    if (this.ignoreNextInput) {
      this.ignoreNextInput = false
      return
    }

    clearTimeout(this.debounceTimer)

    const textarea = this.textareaTarget
    this.cursorPosition = textarea.selectionStart
    const text = textarea.value

    const wordInfo = this.getWordAtCursor(text, this.cursorPosition)
    this.currentWord = wordInfo.word
    this.wordStart = wordInfo.start

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
    let i = currentWordStart - 1

    while (i >= 0 && /\s/.test(text[i])) i--
    if (i < 0) return false

    const prevWordEnd = i
    while (i >= 0 && /[a-zA-Z]/.test(text[i])) i--

    const prevWord = text.substring(i + 1, prevWordEnd + 1)
    return prevWord.length > 0 && /^[A-Z]/.test(prevWord)
  }

  getPreviousWord(text, currentWordStart) {
    let i = currentWordStart - 1

    while (i >= 0 && /\s/.test(text[i])) i--
    if (i < 0) return ""

    const prevWordEnd = i
    while (i >= 0 && /[a-zA-Z]/.test(text[i])) i--

    return text.substring(i + 1, prevWordEnd + 1)
  }

  getWordAtCursor(text, position) {
    let start = position
    let end = position

    while (start > 0 && /[a-zA-Z]/.test(text[start - 1])) start--
    while (end < text.length && /[a-zA-Z]/.test(text[end])) end++

    return { word: text.substring(start, end), start: start, end: end }
  }

  async fetchSuggestions(query) {
    try {
      const textarea = this.textareaTarget
      const text = textarea.value
      const isLowercaseAfterGenus = /^[a-z]/.test(query) && this.hasPrecedingCapitalizedWord(text, this.wordStart)

      if (isLowercaseAfterGenus) {
        const prevGenus = this.getPreviousWord(text, this.wordStart)
        let speciesData = await this.requestJson(
          `${this.speciesUrlValue}?q=${encodeURIComponent(query)}&genus_name=${encodeURIComponent(prevGenus)}`
        )

        // When the app relies on mb_lists fallback (no Species model),
        // species names are stored as full binomials like "Ganoderma sessile".
        // Retry with genus + epithet so fallback matching can return results.
        if (speciesData.length === 0 && prevGenus.length > 0) {
          speciesData = await this.requestJson(
            `${this.speciesUrlValue}?q=${encodeURIComponent(`${prevGenus} ${query}`)}`
          )
        }

        if (speciesData.length > 0) {
          this.renderDropdown(speciesData)
          return
        }
      }

      const genusData = await this.requestJson(
        `${this.genusUrlValue}?q=${encodeURIComponent(query)}`
      )

      if (genusData.length > 0) {
        this.renderDropdown(genusData)
      } else {
        this.hideDropdown()
      }
    } catch (error) {
      console.error("Autocomplete error:", error)
      this.hideDropdown()
    }
  }

  async requestJson(url) {
    const response = await fetch(url, {
      headers: { "Accept": "application/json" },
      cache: "no-store"
    })
    if (!response.ok) return []

    const text = await response.text()
    if (!text) return []

    try {
      const payload = JSON.parse(text)
      return Array.isArray(payload) ? payload : []
    } catch (_error) {
      return []
    }
  }

  renderDropdown(items) {
    this.dropdownTarget.innerHTML = items
      .map((item) => `
        <li class="px-4 py-3 cursor-pointer border-b border-amber-200 last:border-b-0 text-gray-900 hover:bg-amber-100 hover:text-gray-900"
            data-action="click->inline-autocomplete#selectItem"
            data-name="${item.name}">
          <span class="text-base font-semibold">${item.name}</span>
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

    const isLowercaseWord = /^[a-z]/.test(this.currentWord)
    const hasPrevGenus = this.hasPrecedingCapitalizedWord(text, this.wordStart)

    let before
    let after
    let replaceStart

    if (isLowercaseWord && hasPrevGenus) {
      const prevGenus = this.getPreviousWord(text, this.wordStart)
      const genusStart = this.wordStart - prevGenus.length - 1

      replaceStart = genusStart
      before = text.substring(0, genusStart)
      after = text.substring(this.cursorPosition)
    } else {
      replaceStart = this.wordStart
      before = text.substring(0, this.wordStart)
      after = text.substring(this.cursorPosition)
    }

    const isBinomial = selectedName.includes(" ")

    let formattedName
    let cursorOffset
    if (isBinomial) {
      formattedName = `<em>${selectedName}</em>`
      cursorOffset = selectedName.length + 9
    } else {
      formattedName = selectedName + " "
      cursorOffset = selectedName.length + 1
    }

    textarea.value = before + formattedName + after
    this.hideDropdown()

    const newPosition = before.length + cursorOffset
    textarea.setSelectionRange(newPosition, newPosition)
    textarea.focus()

    this.ignoreNextInput = true
    textarea.dispatchEvent(new Event("input", { bubbles: true }))
  }

  hideDropdown() {
    this.dropdownTarget.classList.add("hidden")
    this.dropdownTarget.innerHTML = ""
  }

  onKeydown(event) {
    if (!this.dropdownTarget.classList.contains("hidden")) {
      if (event.key === "Escape") {
        this.hideDropdown()
        event.preventDefault()
      } else if (event.key === "ArrowDown" || event.key === "ArrowUp") {
        event.preventDefault()
      }
    }
  }
}
