import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  togglePanel(event) {
    // Get the target panel ID from the data attribute
    const targetId = event.currentTarget.dataset.toggleTargetParam
    const panel = document.getElementById(targetId)

    if (panel) {
      panel.classList.toggle('hidden')
    } else {
      console.error(`Panel with ID "${targetId}" not found`)
    }
  }
}
