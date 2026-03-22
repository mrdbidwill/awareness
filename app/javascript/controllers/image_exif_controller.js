import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="image-exif"
export default class extends Controller {
  static targets = ["panel", "button"]
  static values = {
    prevUrl: String,
    nextUrl: String
  }

  connect() {
    // Start with panel hidden
    this.panelTarget.classList.add("hidden")

    // Add keyboard navigation
    this.boundHandleKeypress = this.handleKeypress.bind(this)
    document.addEventListener("keydown", this.boundHandleKeypress)
  }

  disconnect() {
    // Clean up event listener when controller is removed
    document.removeEventListener("keydown", this.boundHandleKeypress)
  }

  handleKeypress(event) {
    // Don't interfere if user is typing in an input field
    if (event.target.matches("input, textarea, select")) {
      return
    }

    if (event.key === "ArrowLeft" && this.hasPrevUrlValue) {
      event.preventDefault()
      window.location.href = this.prevUrlValue
    } else if (event.key === "ArrowRight" && this.hasNextUrlValue) {
      event.preventDefault()
      window.location.href = this.nextUrlValue
    }
  }

  toggle() {
    this.panelTarget.classList.toggle("hidden")

    // Update button text
    if (this.panelTarget.classList.contains("hidden")) {
      this.buttonTarget.textContent = "ℹ️ Show EXIF Data"
    } else {
      this.buttonTarget.textContent = "ℹ️ Hide EXIF Data"
    }
  }
}
