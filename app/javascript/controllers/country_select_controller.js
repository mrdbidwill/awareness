import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["countrySelect", "stateSelect"]
  static values = { url: String }

    connect() {
        console.log("Country select controller connected")
        console.log("Country value:", this.countrySelectTarget?.value)
        console.log("URL value:", this.urlValue)
        console.log("State select has options:", this.stateSelectTarget.options.length)

        // If a country is already selected (edit form), populate states immediately
        if (this.countrySelectTarget?.value && this.countrySelectTarget.value !== "") {
            // Save the current state value before we replace the dropdown options
            const currentStateId = this.stateSelectTarget.value
            if (currentStateId) {
                this.stateSelectTarget.setAttribute("data-current", currentStateId)
            }
            this.change()
        }
        // Note: If no country is selected, the form already has the disabled state rendered from the server
    }

  async change() {
    const countryId = this.countrySelectTarget.value
    if (!countryId) {
      this.disableStates("Select a country first")
      return
    }

    try {
      this.stateSelectTarget.disabled = true
      this.setOptions([["", "Loading states…"]])

      const url = `${this.urlValue}?country_id=${encodeURIComponent(countryId)}`
      console.log("Fetching states from:", url)

      const response = await fetch(url, {
        headers: { "Accept": "application/json" },
        credentials: "same-origin"
      })

      console.log("Response status:", response.status, "ok:", response.ok)

      if (!response.ok) {
        const errorText = await response.text()
        console.error("Error response:", errorText)
        throw new Error(`Failed to load states: ${response.status}`)
      }

      const states = await response.json() // Expect [{id, name}, ...]
      console.log("Received states:", states)
      console.log("States is array:", Array.isArray(states), "Length:", states?.length)

      if (!Array.isArray(states) || states.length === 0) {
        console.log("No states found, disabling dropdown")
        this.setOptions([["", "No states available"]])
        this.stateSelectTarget.disabled = true
        return
      }

      const options = [["", "Select a State"], ...states.map(s => [String(s.id), s.name])]
      console.log("Setting options:", options.length, "options")
      const current = this.stateSelectTarget.getAttribute("data-current") || this.stateSelectTarget.value
      console.log("Current state value:", current)
      this.setOptions(options, current)
      console.log("Options set successfully, dropdown should now have", this.stateSelectTarget.options.length, "options")
      // Clear the data-current attribute after first use
      this.stateSelectTarget.removeAttribute("data-current")
      this.stateSelectTarget.disabled = false
      console.log("State dropdown enabled")
    } catch (e) {
      this.setOptions([["", "Could not load states"]])
      this.stateSelectTarget.disabled = true
      console.error("Failed to load states:", e)
    }
  }

  disableStates(placeholderText) {
    this.setOptions([[ "", placeholderText ]])
    this.stateSelectTarget.disabled = true
  }

  setOptions(pairs, selectedValue = null) {
    this.stateSelectTarget.innerHTML = ""
    for (const [value, label] of pairs) {
      const opt = document.createElement("option")
      opt.value = value
      opt.textContent = label
      if (selectedValue && value === selectedValue) opt.selected = true
      this.stateSelectTarget.appendChild(opt)
    }
  }
}
