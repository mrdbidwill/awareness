import { Controller } from "@hotwired/stimulus"

// Manages bulk character updates for edit_characters page
// Allows users to modify multiple character fields and save all at once
// while retaining individual update buttons for single-field updates
export default class extends Controller {
    static targets = ["saveButton", "form", "input"]
    static values = {
        mushroomId: Number,
        redirectPath: String
    }

    connect() {
        // Track original values for dirty state detection
        this.originalValues = new Map()
        this.modifiedFields = new Set()
        window.mrdbidBulkPendingChanges = 0

        // Store original values from all inputs
        this.inputTargets.forEach(input => {
            const key = this.getFieldKey(input)
            this.originalValues.set(key, this.getFieldValue(input))
        })

        this.updateSaveButtonState()
    }

    // Get unique key for a form field
    getFieldKey(input) {
        const form = input.closest('form')
        const characterId = form?.querySelector('input[name="mr_character_id"]')?.value
        const fieldName = input.name
        return `${characterId}-${fieldName}`
    }

    // Get value from input based on type
    getFieldValue(input) {
        if (input.type === 'checkbox') {
            return input.checked
        } else if (input.type === 'radio') {
            // For radio buttons, get the checked one in the group
            const form = input.closest('form')
            const checkedRadio = form?.querySelector(`input[name="${input.name}"]:checked`)
            return checkedRadio?.value || null
        } else {
            return input.value
        }
    }

    // Track field changes
    trackChange(event) {
        const input = event.target
        const key = this.getFieldKey(input)
        const currentValue = this.getFieldValue(input)
        const originalValue = this.originalValues.get(key)

        // Mark field as modified or unmodified
        if (currentValue !== originalValue) {
            this.modifiedFields.add(key)
            this.markFieldAsModified(input)
        } else {
            this.modifiedFields.delete(key)
            this.unmarkFieldAsModified(input)
        }

        this.updateSaveButtonState()
    }

    // Add visual indicator to modified field
    markFieldAsModified(input) {
        const characterCard = input.closest('[data-character-card]')
        if (characterCard) {
            characterCard.classList.add('ring-2', 'ring-yellow-400', 'bg-yellow-50')
            characterCard.dataset.modified = 'true'
        }
    }

    // Remove visual indicator from unmodified field
    unmarkFieldAsModified(input) {
        const characterCard = input.closest('[data-character-card]')
        if (characterCard) {
            characterCard.classList.remove('ring-2', 'ring-yellow-400', 'bg-yellow-50')
            delete characterCard.dataset.modified
        }
    }

    // Update save button text and state
    updateSaveButtonState() {
        const count = this.modifiedFields.size
        window.mrdbidBulkPendingChanges = count

        this.saveButtonTargets.forEach(button => {
            if (count === 0) {
                button.disabled = true
                button.textContent = 'Save All Changes'
                button.classList.remove('bg-green-600', 'hover:bg-green-700')
                button.classList.add('bg-gray-400', 'cursor-not-allowed')
            } else {
                button.disabled = false
                button.textContent = `Save All Changes (${count})`
                button.classList.remove('bg-gray-400', 'cursor-not-allowed')
                button.classList.add('bg-green-600', 'hover:bg-green-700')
            }
        })
    }

    // Collect all modified fields and submit via bulk update
    saveAll(event) {
        event.preventDefault()

        if (this.modifiedFields.size === 0) {
            return
        }

        // Collect all modified character data
        const updates = []

        this.formTargets.forEach(form => {
            const characterId = form.querySelector('input[name="mr_character_id"]')?.value
            if (!characterId) return

            // Check if any field in this form is modified
            const hasModifiedField = Array.from(this.modifiedFields).some(key =>
                key.startsWith(`${characterId}-`)
            )

            if (!hasModifiedField) return

            // Collect the character value
            const valueInput = form.querySelector('input[name="character_value"], select[name="character_value"], textarea[name="character_value"]')
            if (!valueInput) return

            const value = this.getFieldValue(valueInput)

            updates.push({
                mr_character_id: characterId,
                character_value: value
            })
        })

        if (updates.length === 0) {
            alert('No changes to save.')
            return
        }

        // Create a form to submit the bulk update
        const form = document.createElement('form')
        form.method = 'POST'
        form.action = '/mr_character_mushrooms/bulk_update'

        // Add CSRF token
        const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
        if (csrfToken) {
            const csrfInput = document.createElement('input')
            csrfInput.type = 'hidden'
            csrfInput.name = 'authenticity_token'
            csrfInput.value = csrfToken
            form.appendChild(csrfInput)
        }

        // Add mushroom ID
        const mushroomInput = document.createElement('input')
        mushroomInput.type = 'hidden'
        mushroomInput.name = 'mushroom_id'
        mushroomInput.value = this.mushroomIdValue
        form.appendChild(mushroomInput)

        // Add redirect path
        if (this.redirectPathValue) {
            const redirectInput = document.createElement('input')
            redirectInput.type = 'hidden'
            redirectInput.name = 'redirect_to'
            redirectInput.value = this.redirectPathValue
            form.appendChild(redirectInput)
        }

        // Add each update as hidden field
        updates.forEach((update, index) => {
            const characterIdInput = document.createElement('input')
            characterIdInput.type = 'hidden'
            characterIdInput.name = `updates[${index}][mr_character_id]`
            characterIdInput.value = update.mr_character_id
            form.appendChild(characterIdInput)

            const valueInput = document.createElement('input')
            valueInput.type = 'hidden'
            valueInput.name = `updates[${index}][character_value]`
            valueInput.value = update.character_value
            form.appendChild(valueInput)
        })

        // Submit the form
        document.body.appendChild(form)
        form.submit()
    }

    // Reset all modified field indicators (called after successful save)
    resetModifiedState() {
        this.modifiedFields.clear()
        window.mrdbidBulkPendingChanges = 0

        // Remove all visual indicators
        this.element.querySelectorAll('[data-modified="true"]').forEach(card => {
            card.classList.remove('ring-2', 'ring-yellow-400', 'bg-yellow-50')
            delete card.dataset.modified
        })

        // Update original values to current values
        this.inputTargets.forEach(input => {
            const key = this.getFieldKey(input)
            this.originalValues.set(key, this.getFieldValue(input))
        })

        this.updateSaveButtonState()
    }
}
