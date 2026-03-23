import { Controller } from "@hotwired/stimulus"

// Inline mycological term suggestions for text inputs/textareas and subject helper input.
// Uses the Mycowriter autocomplete endpoint and inserts/chooses the selected value.
export default class extends Controller {
  static targets = ["input", "dropdown", "status"]

  static values = {
    url: String,
    min: { type: Number, default: 4 },
    mode: { type: String, default: "text" },
    selectId: String
  }

  connect() {
    this.debounceTimer = null
    this.lastResults = []
    this.boundDocumentClick = this.handleDocumentClick.bind(this)
    document.addEventListener("click", this.boundDocumentClick)
  }

  disconnect() {
    clearTimeout(this.debounceTimer)
    document.removeEventListener("click", this.boundDocumentClick)
  }

  onInput() {
    clearTimeout(this.debounceTimer)
    const query = this.currentQuery()

    if (query.length < this.minValue) {
      this.hideDropdown()
      return
    }

    this.debounceTimer = setTimeout(() => {
      this.fetchSuggestions(query)
    }, 150)
  }

  onBlur() {
    // Let click events on dropdown run before hiding.
    setTimeout(() => this.hideDropdown(), 120)
  }

  choose(event) {
    event.preventDefault()
    const value = event.currentTarget.dataset.value
    if (!value) return

    if (this.modeValue === "subject") {
      this.selectSubject(value)
    } else {
      this.insertAtCursor(value)
    }

    this.hideDropdown()
  }

  fetchSuggestions(query) {
    if (!this.hasUrlValue) return

    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("q", query)

    fetch(url, {
      headers: { Accept: "application/json" },
      cache: "no-store"
    })
      .then((response) => {
        if (!response.ok) return []
        return response.text().then((text) => {
          if (!text) return []
          try {
            return JSON.parse(text)
          } catch (_error) {
            return []
          }
        })
      })
      .then((items) => {
        this.lastResults = Array.isArray(items) ? items : []
        this.renderDropdown()
      })
      .catch(() => {
        this.lastResults = []
        this.hideDropdown()
      })
  }

  renderDropdown() {
    if (!this.hasDropdownTarget) return

    if (this.lastResults.length === 0) {
      this.dropdownTarget.innerHTML = "<div class='px-3 py-2 text-sm text-gray-500'>No Mycowriter matches found.</div>"
      this.dropdownTarget.classList.remove("hidden")
      return
    }

    const optionsHtml = this.lastResults.map((item) => {
      const label = this.escapeHtml(item.name || "")
      return `<button type="button"
                      class="block w-full px-3 py-2 text-left text-sm hover:bg-emerald-50"
                      data-action="mousedown->mycowriter-inline#choose"
                      data-value="${label}">${label}</button>`
    }).join("")

    this.dropdownTarget.innerHTML = optionsHtml
    this.dropdownTarget.classList.remove("hidden")
  }

  hideDropdown() {
    if (!this.hasDropdownTarget) return
    this.dropdownTarget.classList.add("hidden")
    this.dropdownTarget.innerHTML = ""
  }

  currentQuery() {
    if (!this.hasInputTarget) return ""

    const value = this.inputTarget.value || ""
    const cursor = this.inputTarget.selectionStart ?? value.length
    const beforeCursor = value.slice(0, cursor)
    const match = beforeCursor.match(/([A-Za-z][A-Za-z-]*)$/)
    return (match ? match[1] : value.trim()).trim()
  }

  insertAtCursor(selectedValue) {
    if (!this.hasInputTarget) return

    const value = this.inputTarget.value || ""
    const selectionStart = this.inputTarget.selectionStart ?? value.length
    const selectionEnd = this.inputTarget.selectionEnd ?? selectionStart

    const before = value.slice(0, selectionStart)
    const after = value.slice(selectionEnd)
    const tokenMatch = before.match(/([A-Za-z][A-Za-z-]*)$/)

    const tokenStart = tokenMatch ? selectionStart - tokenMatch[1].length : selectionStart
    const nextValue = `${value.slice(0, tokenStart)}${selectedValue}${after}`
    const nextCursor = tokenStart + selectedValue.length

    this.inputTarget.value = nextValue
    this.inputTarget.setSelectionRange(nextCursor, nextCursor)
    this.inputTarget.focus()
    this.inputTarget.dispatchEvent(new Event("input", { bubbles: true }))
  }

  selectSubject(selectedValue) {
    if (!this.hasInputTarget) return
    this.inputTarget.value = selectedValue

    const select = this.findSubjectSelect()
    if (!select) return

    const normalized = selectedValue.trim().toLowerCase()
    const options = Array.from(select.options)
    const match = options.find((option) => option.text.trim().toLowerCase() === normalized)

    if (match) {
      select.value = match.value
      select.dispatchEvent(new Event("change", { bubbles: true }))
      this.setStatus(`Matched subject: ${match.text}`)
    } else {
      this.setStatus(`No exact subject match for "${selectedValue}".`)
    }
  }

  findSubjectSelect() {
    if (!this.hasSelectIdValue) return null
    return document.getElementById(this.selectIdValue)
  }

  setStatus(message) {
    if (!this.hasStatusTarget) return
    this.statusTarget.textContent = message
  }

  handleDocumentClick(event) {
    if (!this.element.contains(event.target)) {
      this.hideDropdown()
    }
  }

  escapeHtml(value) {
    const text = document.createElement("textarea")
    text.textContent = value
    return text.innerHTML
  }
}
