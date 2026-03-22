import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="source-data-autocomplete"
export default class extends Controller {
  static targets = ["input", "dropdown", "hiddenField"]
  static values = {
    sources: Array
  }

  connect() {
    // Close dropdown when clicking outside
    this.boundCloseOnClickOutside = this.closeOnClickOutside.bind(this)
    document.addEventListener('click', this.boundCloseOnClickOutside)
  }

  disconnect() {
    document.removeEventListener('click', this.boundCloseOnClickOutside)
  }

  closeOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideDropdown()
    }
  }

  onInput(event) {
    const query = event.target.value.toLowerCase().trim()

    if (query.length === 0) {
      this.hideDropdown()
      this.hiddenFieldTarget.value = ''
      this.updateBorderColor('')
      return
    }

    // Filter sources based on input
    const matches = this.sourcesValue.filter(source =>
      source.title.toLowerCase().includes(query)
    )

    if (matches.length > 0) {
      this.showDropdown(matches)
    } else {
      this.hideDropdown()
    }

    // Update border color for visual feedback
    const exactMatch = this.sourcesValue.find(source =>
      source.title.toLowerCase() === query
    )

    if (exactMatch) {
      this.hiddenFieldTarget.value = exactMatch.id
      this.updateBorderColor('green')
    } else {
      this.hiddenFieldTarget.value = ''
      this.updateBorderColor(query.length > 0 ? 'red' : '')
    }
  }

  showDropdown(matches) {
    // Clear existing items
    this.dropdownTarget.innerHTML = ''

    // Add matched items (limit to 20 for performance)
    matches.slice(0, 20).forEach(source => {
      const li = document.createElement('li')
      li.className = 'px-3 py-2 hover:bg-blue-100 cursor-pointer text-sm'
      li.textContent = source.title
      li.dataset.sourceId = source.id
      li.dataset.sourceTitle = source.title
      li.dataset.action = 'click->source-data-autocomplete#selectSource'
      this.dropdownTarget.appendChild(li)
    })

    this.dropdownTarget.classList.remove('hidden')
  }

  hideDropdown() {
    this.dropdownTarget.classList.add('hidden')
  }

  selectSource(event) {
    const sourceId = event.currentTarget.dataset.sourceId
    const sourceTitle = event.currentTarget.dataset.sourceTitle

    this.inputTarget.value = sourceTitle
    this.hiddenFieldTarget.value = sourceId
    this.hideDropdown()
    this.updateBorderColor('green')
  }

  updateBorderColor(color) {
    if (color === 'green') {
      this.inputTarget.style.borderColor = '#10b981'
      this.inputTarget.style.borderWidth = '2px'
    } else if (color === 'red') {
      this.inputTarget.style.borderColor = '#ef4444'
      this.inputTarget.style.borderWidth = '2px'
    } else {
      this.inputTarget.style.borderColor = '#9ca3af'
      this.inputTarget.style.borderWidth = '1px'
    }
  }
}
