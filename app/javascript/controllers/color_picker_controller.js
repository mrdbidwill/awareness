import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["colorValue", "selectedColorLabel", "submitButton", "modal"]
    static values = { mushroomId: Number }

    open(event) {
        const characterId = event.currentTarget.dataset.characterId
        const modal = document.getElementById(`colorPickerModal${characterId}`)
        if (modal) {
            modal.classList.remove('hidden')
            document.body.style.overflow = 'hidden'
        }
    }

    close(event) {
        // Find the modal by traversing up from the clicked element
        const modal = event.currentTarget.closest('[id^="colorPickerModal"]')
        if (modal) {
            modal.classList.add('hidden')
            document.body.style.overflow = ''
        }
    }

    closeOnBackdrop(event) {
        // Only close if clicking directly on the backdrop
        if (event.target === event.currentTarget) {
            event.currentTarget.classList.add('hidden')
            document.body.style.overflow = ''
        }
    }

    stopPropagation(event) {
        event.stopPropagation()
    }

    selectColor(event) {
        const colorId = event.params.colorId
        this.colorValueTargets.forEach((t) => (t.value = colorId))
        this.selectedColorLabelTarget.textContent = `ID ${colorId}`
        this.submitButtonTargets.forEach((b) => (b.disabled = false))
    }

    // Close on Escape key
    connect() {
        this.escapeHandler = this.handleEscape.bind(this)
        document.addEventListener('keydown', this.escapeHandler)
    }

    disconnect() {
        document.removeEventListener('keydown', this.escapeHandler)
    }

    handleEscape(event) {
        if (event.key === 'Escape') {
            const modals = document.querySelectorAll('[id^="colorPickerModal"]:not(.hidden)')
            modals.forEach(modal => {
                modal.classList.add('hidden')
                document.body.style.overflow = ''
            })
        }
    }
}