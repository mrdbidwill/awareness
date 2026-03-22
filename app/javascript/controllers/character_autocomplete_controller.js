import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="character-autocomplete"
export default class extends Controller {
  static targets = ["input", "dropdown", "hiddenField"]
  static values = {
    url: String
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
    const query = event.target.value.trim()

    if (query.length < 2) {
      this.hideDropdown()
      this.hiddenFieldTarget.value = ''
      this.updateBorderColor('')
      return
    }

    // Fetch character suggestions from server
    fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`)
      .then(response => response.json())
      .then(characters => {
        if (characters.length > 0) {
          this.showDropdown(characters)
        } else {
          this.hideDropdown()
        }
      })
      .catch(error => {
        console.error('Error fetching characters:', error)
        this.hideDropdown()
      })
  }

  showDropdown(characters) {
    // Clear existing items
    this.dropdownTarget.innerHTML = ''

    // Add matched items
    characters.forEach(character => {
      const li = document.createElement('li')
      li.className = 'px-3 py-2 hover:bg-blue-100 cursor-pointer text-sm'
      li.textContent = character.name
      li.dataset.characterId = character.id
      li.dataset.characterName = character.name
      li.dataset.action = 'click->character-autocomplete#selectCharacter'
      this.dropdownTarget.appendChild(li)
    })

    this.dropdownTarget.classList.remove('hidden')
  }

  hideDropdown() {
    this.dropdownTarget.classList.add('hidden')
  }

  selectCharacter(event) {
    const characterId = event.currentTarget.dataset.characterId
    const characterName = event.currentTarget.dataset.characterName

    this.inputTarget.value = characterName
    this.hiddenFieldTarget.value = characterId
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
