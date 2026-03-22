import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "modalContent", "tooltip"]
  static values = {
    url: { type: String, default: "/glossary/definition" }
  }

  connect() {
    this.tooltipElement = null
    this.currentTerm = null
    this.definitionCache = new Map()

    // Add event listeners to all glossary terms
    this.attachGlossaryListeners()
  }

  disconnect() {
    this.removeTooltip()
  }

  attachGlossaryListeners() {
    document.querySelectorAll('.glossary-term').forEach(term => {
      term.addEventListener('mouseenter', this.showTooltip.bind(this))
      term.addEventListener('mouseleave', this.hideTooltip.bind(this))
      term.addEventListener('click', this.showModal.bind(this))
      term.addEventListener('keydown', this.handleKeydown.bind(this))
    })
  }

  showTooltip(event) {
    const term = event.target.dataset.term
    if (!term) return

    this.currentTerm = term

    // Show loading tooltip
    this.createTooltip(event.target, 'Loading...')

    // Fetch definition
    this.fetchDefinition(term).then(definition => {
      if (this.currentTerm === term) {
        this.updateTooltip(this.truncateDefinition(definition, 150))
      }
    })
  }

  hideTooltip(event) {
    // Small delay to allow moving to modal
    setTimeout(() => {
      if (!this.modalOpen) {
        this.removeTooltip()
      }
    }, 100)
  }

  createTooltip(element, content) {
    this.removeTooltip()

    this.tooltipElement = document.createElement('div')
    this.tooltipElement.className = 'glossary-tooltip'
    this.tooltipElement.innerHTML = content
    document.body.appendChild(this.tooltipElement)

    this.positionTooltip(element)
  }

  updateTooltip(content) {
    if (this.tooltipElement) {
      this.tooltipElement.innerHTML = content
    }
  }

  removeTooltip() {
    if (this.tooltipElement) {
      this.tooltipElement.remove()
      this.tooltipElement = null
    }
    this.currentTerm = null
  }

  positionTooltip(element) {
    if (!this.tooltipElement) return

    const rect = element.getBoundingClientRect()
    const tooltipRect = this.tooltipElement.getBoundingClientRect()

    let top = rect.bottom + window.scrollY + 5
    let left = rect.left + window.scrollX

    // Adjust if tooltip goes off screen
    if (left + tooltipRect.width > window.innerWidth) {
      left = window.innerWidth - tooltipRect.width - 10
    }

    if (top + tooltipRect.height > window.innerHeight + window.scrollY) {
      top = rect.top + window.scrollY - tooltipRect.height - 5
    }

    this.tooltipElement.style.top = `${top}px`
    this.tooltipElement.style.left = `${left}px`
  }

  showModal(event) {
    event.preventDefault()
    const term = event.target.dataset.term
    if (!term) return

    this.modalOpen = true
    this.removeTooltip()

    // Create modal if it doesn't exist
    if (!this.hasModalTarget) {
      this.createModal()
    }

    this.modalTarget.querySelector('.glossary-modal-content').innerHTML = '<p>Loading...</p>'
    this.modalTarget.classList.add('active')
    this.modalTarget.querySelector('.glossary-modal-title').textContent = term

    this.fetchDefinition(term).then(definition => {
      const content = this.modalTarget.querySelector('.glossary-modal-content')
      content.innerHTML = `
        <p>${definition}</p>
        <p class="glossary-attribution">
          <small>Source: <a href="https://en.wikipedia.org/wiki/Glossary_of_mycology" target="_blank" rel="noopener">Wikipedia Glossary of Mycology</a> (CC BY-SA 4.0)</small>
        </p>
      `
    })
  }

  hideModal() {
    if (this.hasModalTarget) {
      this.modalTarget.classList.remove('active')
    }
    this.modalOpen = false
  }

  createModal() {
    const modal = document.createElement('div')
    modal.className = 'glossary-modal'
    modal.dataset.glossaryTarget = 'modal'
    modal.innerHTML = `
      <div class="glossary-modal-backdrop" data-action="click->glossary#hideModal"></div>
      <div class="glossary-modal-dialog">
        <div class="glossary-modal-header">
          <h3 class="glossary-modal-title"></h3>
          <button type="button" class="glossary-modal-close" data-action="click->glossary#hideModal">&times;</button>
        </div>
        <div class="glossary-modal-body">
          <div class="glossary-modal-content"></div>
        </div>
      </div>
    `
    document.body.appendChild(modal)
  }

  handleKeydown(event) {
    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault()
      this.showModal(event)
    }
  }

  async fetchDefinition(term) {
    // Check cache first
    if (this.definitionCache.has(term)) {
      return this.definitionCache.get(term)
    }

    try {
      const response = await fetch(`${this.urlValue}?term=${encodeURIComponent(term)}`, {
        headers: {
          'Accept': 'application/json'
        }
      })

      if (!response.ok) {
        throw new Error('Failed to fetch definition')
      }

      const data = await response.json()
      const definition = data.definition || 'Definition not found.'

      // Cache the definition
      this.definitionCache.set(term, definition)

      return definition
    } catch (error) {
      console.error('Error fetching glossary definition:', error)
      return 'Unable to load definition.'
    }
  }

  truncateDefinition(text, maxLength) {
    if (text.length <= maxLength) return text
    return text.substring(0, maxLength) + '... <em>(click for more)</em>'
  }
}
