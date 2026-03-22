import { Controller } from "@hotwired/stimulus"

// Manages multi-color selection for color characters
// Allows selecting multiple colors with ordering (primary, secondary, etc.)
export default class extends Controller {
    static targets = ["selectedColors", "colorGrid", "form"]
    static values = {
        characterId: Number,
        selectedIds: Array,
        colorHexMap: Object,
        colorImages: Object
    }

    connect() {
        // Initialize selected colors from data attribute
        this.selectedColors = this.selectedIdsValue || []
        // Store original selection for cancel/reset
        this.originalColors = [...this.selectedColors]
        this.renderSelectedColors()
        // Don't update grid highlights until modal is opened
        // This prevents issues with hidden modals

        // Escape key handler
        this.escapeHandler = this.handleEscape.bind(this)
        document.addEventListener('keydown', this.escapeHandler)
    }

    disconnect() {
        document.removeEventListener('keydown', this.escapeHandler)
    }

    handleEscape(event) {
        if (event.key === 'Escape') {
            this.close()
        }
    }

    open(event) {
        const characterId = event.currentTarget.dataset.characterId
        const modal = document.getElementById(`colorPickerModal${characterId}`)
        if (modal) {
            if (this.hasPendingBulkChanges()) {
                const ok = confirm(`You have ${window.mrdbidBulkPendingChanges} unsaved change(s). If you continue and save colors, those changes will be lost. Click Cancel to go back and use "Save All Changes".`)
                if (!ok) return
            }
            modal.classList.remove('hidden')
            document.body.style.overflow = 'hidden'
            // Ensure grid highlights are updated when modal opens
            this.updateGridHighlights()
        }
    }

    close() {
        // Reset to original selection on cancel
        this.selectedColors = [...this.originalColors]
        this.renderSelectedColors()
        this.updateGridHighlights()

        // Find the modal within this controller's element (not ancestor)
        const modal = this.element.querySelector('[id^="colorPickerModal"]')
        if (modal) {
            modal.classList.add('hidden')
            document.body.style.overflow = ''
        }
    }

    closeOnBackdrop(event) {
        if (event.target === event.currentTarget) {
            this.close()
        }
    }

    stopPropagation(event) {
        event.stopPropagation()
    }

    // Toggle color selection (add or remove)
    toggleColor(event) {
        event.preventDefault()
        const colorId = parseInt(event.currentTarget.value || event.currentTarget.dataset.colorId)

        const index = this.selectedColors.indexOf(colorId)
        if (index > -1) {
            // Remove color
            this.selectedColors.splice(index, 1)
        } else {
            // Add color
            this.selectedColors.push(colorId)
        }

        this.renderSelectedColors()
        this.updateGridHighlights()
    }

    // Remove color from selected list
    removeColor(event) {
        const colorId = parseInt(event.currentTarget.dataset.colorId)
        const index = this.selectedColors.indexOf(colorId)
        if (index > -1) {
            this.selectedColors.splice(index, 1)
            this.renderSelectedColors()
            this.updateGridHighlights()
        }
    }

    // Move color up in order (decrease index, higher priority)
    moveUp(event) {
        const colorId = parseInt(event.currentTarget.dataset.colorId)
        const index = this.selectedColors.indexOf(colorId)
        if (index > 0) {
            [this.selectedColors[index - 1], this.selectedColors[index]] =
            [this.selectedColors[index], this.selectedColors[index - 1]]
            this.renderSelectedColors()
        }
    }

    // Move color down in order (increase index, lower priority)
    moveDown(event) {
        const colorId = parseInt(event.currentTarget.dataset.colorId)
        const index = this.selectedColors.indexOf(colorId)
        if (index > -1 && index < this.selectedColors.length - 1) {
            [this.selectedColors[index], this.selectedColors[index + 1]] =
            [this.selectedColors[index + 1], this.selectedColors[index]]
            this.renderSelectedColors()
        }
    }

    // Clear all selected colors
    clearAll(event) {
        event.preventDefault()
        if (confirm('Clear all colors for this character?')) {
            this.selectedColors = []
            this.renderSelectedColors()
            this.updateGridHighlights()
        }
    }

    // Submit the form with selected colors (or empty to delete)
    submitColors(event) {
        event.preventDefault()
        if (this.hasPendingBulkChanges()) {
            const ok = confirm(`You have ${window.mrdbidBulkPendingChanges} unsaved change(s). Saving colors now will discard them. Continue?`)
            if (!ok) return
        }

        // Add each color ID to the form before submitting
        // Remove any existing color_ids[] inputs first
        const existingInputs = this.formTarget.querySelectorAll('input[name="color_ids[]"]')
        existingInputs.forEach(input => input.remove())

        // Add hidden inputs for each selected color
        this.selectedColors.forEach(colorId => {
            const input = document.createElement('input')
            input.type = 'hidden'
            input.name = 'color_ids[]'
            input.value = colorId
            this.formTarget.appendChild(input)
        })

        // Update original colors so cancel works correctly
        this.originalColors = [...this.selectedColors]

        // Let Turbo handle the form submission normally
        // This will follow the redirect and show the flash message
        this.formTarget.requestSubmit()
    }

    hasPendingBulkChanges() {
        return Number(window.mrdbidBulkPendingChanges || 0) > 0
    }

    // Render selected color chips/badges
    renderSelectedColors() {
        if (!this.hasSelectedColorsTarget) return

        if (this.selectedColors.length === 0) {
            this.selectedColorsTarget.innerHTML = '<p class="text-sm text-gray-500">No colors selected</p>'
            return
        }

        const html = this.selectedColors.map((colorId, index) => {
            const isFirst = index === 0
            const isLast = index === this.selectedColors.length - 1
            const label = index === 0 ? 'Primary' : `Secondary ${index}`

            // Get the hex color and image URL from the mappings provided by Rails
            const hexColor = this.colorHexMapValue[colorId]
            const imageUrl = this.colorImagesValue[colorId]

            // Render color swatch - use image for AMS colors if available, otherwise hex
            const colorDisplay = imageUrl
                ? `<img src="${imageUrl}" alt="Color ${colorId}" class="w-8 h-8 rounded border border-gray-400" />`
                : `<div class="w-8 h-8 rounded border border-gray-400" style="background-color: ${hexColor}"></div>`

            return `
                <div class="flex items-center gap-2 p-2 bg-gray-50 rounded border ${isFirst ? 'border-blue-500 border-2' : 'border-gray-300'}">
                    ${colorDisplay}
                    <span class="text-sm font-medium">${label}</span>
                    <div class="flex gap-1 ml-auto">
                        ${!isFirst ? `
                            <button type="button"
                                    data-action="click->multicolor-picker#moveUp"
                                    data-color-id="${colorId}"
                                    class="p-1 hover:bg-gray-200 rounded"
                                    title="Move up">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 15l7-7 7 7" />
                                </svg>
                            </button>
                        ` : ''}
                        ${!isLast ? `
                            <button type="button"
                                    data-action="click->multicolor-picker#moveDown"
                                    data-color-id="${colorId}"
                                    class="p-1 hover:bg-gray-200 rounded"
                                    title="Move down">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                                </svg>
                            </button>
                        ` : ''}
                        <button type="button"
                                data-action="click->multicolor-picker#removeColor"
                                data-color-id="${colorId}"
                                class="p-1 hover:bg-red-100 text-red-600 rounded"
                                title="Remove">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                            </svg>
                        </button>
                    </div>
                </div>
            `
        }).join('')

        this.selectedColorsTarget.innerHTML = html
    }

    // Update visual highlights in the color grid
    updateGridHighlights() {
        if (!this.hasColorGridTarget) return

        const buttons = this.colorGridTarget.querySelectorAll('button[data-color-id]')
        buttons.forEach(button => {
            const colorId = parseInt(button.dataset.colorId)
            const isSelected = this.selectedColors.includes(colorId)

            // Remove any existing checkmark overlays (both server-rendered and JS-created)
            // Look for any div with the 'checkmark-overlay' class
            const existingOverlays = button.querySelectorAll('.checkmark-overlay')
            existingOverlays.forEach(overlay => overlay.remove())

            if (isSelected) {
                button.classList.add('ring-2', 'ring-blue-500', 'border-blue-500')
                button.classList.remove('border-gray-300')

                // Add checkmark badge in top-right corner - doesn't cover the color image
                const checkmark = document.createElement('div')
                checkmark.className = 'checkmark-overlay absolute top-0 right-0 m-0.5'
                checkmark.innerHTML = `
                  <div class="bg-blue-600 rounded-full p-0.5 shadow-lg">
                    <svg class="w-3 h-3 text-white" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
                    </svg>
                  </div>
                `
                button.appendChild(checkmark)
            } else {
                button.classList.remove('ring-2', 'ring-blue-500', 'border-blue-500')
                button.classList.add('border-gray-300')
            }
        })
    }
}
