import { Controller } from "@hotwired/stimulus"

// Drag-and-drop ordering that writes sequence numbers into the inputs.
export default class extends Controller {
  static targets = ["row"]

  connect() {
    this.rowTargets.forEach((row) => {
      row.setAttribute("draggable", "true")
      row.addEventListener("dragstart", this.onDragStart)
      row.addEventListener("dragover", this.onDragOver)
      row.addEventListener("drop", this.onDrop)
      row.addEventListener("dragend", this.onDragEnd)
    })

    this.reindex()
  }

  disconnect() {
    this.rowTargets.forEach((row) => {
      row.removeEventListener("dragstart", this.onDragStart)
      row.removeEventListener("dragover", this.onDragOver)
      row.removeEventListener("drop", this.onDrop)
      row.removeEventListener("dragend", this.onDragEnd)
    })
  }

  onDragStart = (event) => {
    this.draggingRow = event.currentTarget
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", this.draggingRow.dataset.characterId)
    this.draggingRow.classList.add("opacity-50")
  }

  onDragOver = (event) => {
    event.preventDefault()
    const target = event.currentTarget
    if (!this.draggingRow || target === this.draggingRow) return

    const rect = target.getBoundingClientRect()
    const before = event.clientY < rect.top + rect.height / 2
    const parent = target.parentNode
    if (before) {
      parent.insertBefore(this.draggingRow, target)
    } else {
      parent.insertBefore(this.draggingRow, target.nextSibling)
    }
  }

  onDrop = (event) => {
    event.preventDefault()
    this.reindex()
  }

  onDragEnd = () => {
    if (this.draggingRow) {
      this.draggingRow.classList.remove("opacity-50")
    }
    this.draggingRow = null
  }

  reindex() {
    this.element.querySelectorAll("tbody tr").forEach((row, idx) => {
      const input = row.querySelector("input[type='number']")
      if (input) input.value = idx + 1
    })
  }
}
