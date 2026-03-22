import { Controller } from "@hotwired/stimulus"

// Character search autocomplete controller
// Usage: data-controller="character-search"
export default class extends Controller {
    static targets = ["input", "dropdown", "loader"]
    static values = {
        mushroomId: String,
        coreOnly: Boolean
    }

    connect() {
        this.debounceTimer = null
        this.inputTarget.addEventListener("input", this.onInput.bind(this))
        this.inputTarget.addEventListener("focus", this.onInput.bind(this))
        this.dropdownTarget.addEventListener("click", this.onDropdownClick.bind(this))

        // Close dropdown when clicking outside
        document.addEventListener("click", this.onDocumentClick.bind(this))
    }

    disconnect() {
        document.removeEventListener("click", this.onDocumentClick.bind(this))
    }

    onDocumentClick(e) {
        if (!this.element.contains(e.target)) {
            this.hideDropdown()
        }
    }

    onInput() {
        clearTimeout(this.debounceTimer)
        let query = this.inputTarget.value.trim()

        // Show immediate feedback
        const minLength = parseInt(this.inputTarget.getAttribute("minlength")) || 3
        if(query.length > 0 && query.length < minLength) {
            this.dropdownTarget.innerHTML = `<li class='px-3 py-2 text-sm text-gray-400'>Type ${minLength - query.length} more character(s)...</li>`
            this.dropdownTarget.classList.remove("hidden")
            return
        }

        if(query.length < minLength) {
            this.hideDropdown()
            return
        }

        // Show loading immediately before debounce
        this.showLoader()
        this.debounceTimer = setTimeout(() => {
            this.autocomplete(query)
        }, 200)
    }

    autocomplete(query) {
        this.showLoader()
        const url = new URL("/autocomplete/mr_characters", window.location.origin)
        url.searchParams.append("q", query)

        if(this.hasMushroomIdValue) {
            url.searchParams.append("mushroom_id", this.mushroomIdValue)
        }
        if(this.hasCoreOnlyValue) {
            url.searchParams.append("core_only", this.coreOnlyValue)
        }

        fetch(url, { headers: {"Accept": "application/json"} })
            .then(r => r.json())
            .then(items => {
                this.renderDropdown(items)
            })
            .catch(_err => this.hideDropdown())
            .finally(() => this.hideLoader())
    }

    renderDropdown(items) {
        if(!items.length) {
            this.dropdownTarget.innerHTML = `
                <li class='px-3 py-2 text-sm text-gray-400'>
                    No matching characters found.
                    <span class="block text-xs mt-1">Try a different search term or load characters by part below.</span>
                </li>`
            this.dropdownTarget.classList.remove("hidden")
            return
        }

        this.dropdownTarget.innerHTML = items
            .map(item =>
                `<li class="hover:bg-blue-100 cursor-pointer px-3 py-2 border-b last:border-b-0"
                     data-id="${item.id}"
                     data-label="${this.escapeHtml(item.name)}"
                     data-part="${this.escapeHtml(item.part_name || '')}">
                    <div class="text-sm font-medium">${this.escapeHtml(item.name)}</div>
                    <div class="text-xs text-gray-500">${item.is_color ? 'Opens color chart (family colors → AMS)' : 'Click to add this character'}</div>
                </li>`
            ).join("")
        this.dropdownTarget.classList.remove("hidden")
    }

    hideDropdown() {
        this.dropdownTarget.classList.add("hidden")
        this.dropdownTarget.innerHTML = ""
    }

    showLoader() {
        if(this.hasLoaderTarget) this.loaderTarget.classList.remove("hidden")
    }

    hideLoader() {
        if(this.hasLoaderTarget) this.loaderTarget.classList.add("hidden")
    }

    onDropdownClick(e) {
        const li = e.target.closest("li[data-id]")
        if(!li) return

        const characterId = li.dataset.id
        const characterName = li.dataset.label
        const partName = li.dataset.part

        // Load the part section if not already loaded
        this.loadPartAndScrollToCharacter(partName, characterId, characterName)
    }

    loadPartAndScrollToCharacter(partName, characterId, characterName) {
        // Close dropdown and clear input
        this.hideDropdown()
        this.inputTarget.value = ""

        if(this.hasCoreOnlyValue && this.coreOnlyValue) {
            const coreEntryUrl = this.element.dataset.coreEntryUrl
            if(coreEntryUrl) {
                const url = new URL(coreEntryUrl, window.location.origin)
                url.searchParams.set("focus_character_id", characterId)
                window.location.href = url.toString()
                return
            }
        }

        // Build URL to load this part
        const url = new URL(window.location.href)
        url.searchParams.set("show_part", partName)
        url.searchParams.set("show_character_id", characterId)

        // Navigate to load the part (will reload page)
        window.location.href = url.toString()

        // After reload, scroll to the character
        // (This happens on next page load, so we use sessionStorage)
        sessionStorage.setItem("scrollToCharacter", characterId)
        sessionStorage.setItem("highlightCharacter", characterId)
    }

    escapeHtml(text) {
        const div = document.createElement('div')
        div.textContent = text
        return div.innerHTML
    }
}
