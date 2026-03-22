import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "charCount"]
  static values = { maxLength: { type: Number, default: 16777215 } }

  connect() {
    this.updateCharCount()
  }

  insertParagraph() {
    const textarea = this.textareaTarget
    const start = textarea.selectionStart
    const end = textarea.selectionEnd
    const value = textarea.value
    const selectedText = value.substring(start, end)

    if (selectedText) {
      // Wrap selected text in <p> tags with class
      const newValue = value.substring(0, start) + '<p class="p-mrdbid">' + selectedText + '</p>' + value.substring(end)
      textarea.value = newValue
      // Position cursor after the closing tag
      const newPos = start + selectedText.length + 27 // length of '<p class="p-mrdbid">' + '</p>'
      textarea.setSelectionRange(newPos, newPos)
    } else {
      // Insert paragraph break (double newline)
      const newValue = value.substring(0, start) + '\n\n' + value.substring(start)
      textarea.value = newValue
      // Move cursor after the inserted newlines
      const newPos = start + 2
      textarea.setSelectionRange(newPos, newPos)
    }

    textarea.focus()
    textarea.dispatchEvent(new Event('input', { bubbles: true }))
  }

  makeBold() {
    this.wrapSelection('<strong>', '</strong>')
  }

  makeItalic() {
    this.wrapSelection('<em>', '</em>')
  }

  makeUnderline() {
    this.wrapSelection('<u>', '</u>')
  }

  makeStrikethrough() {
    this.wrapSelection('<s>', '</s>')
  }

  makeH1() {
    this.wrapSelection('<h1>', '</h1>')
  }

  makeH2() {
    this.wrapSelection('<h2>', '</h2>')
  }

  makeH3() {
    this.wrapSelection('<h3>', '</h3>')
  }

  makeBulletList() {
    this.wrapListItem('<ul>', '</ul>', '<li>', '</li>')
  }

  makeNumberedList() {
    this.wrapListItem('<ol>', '</ol>', '<li>', '</li>')
  }

  insertLink() {
    const textarea = this.textareaTarget
    const start = textarea.selectionStart
    const end = textarea.selectionEnd
    const value = textarea.value
    const selectedText = value.substring(start, end)

    if (selectedText) {
      // Wrap selected text as link
      const newValue = value.substring(0, start) + '<a href="url" class="text-blue-600 underline">' + selectedText + '</a>' + value.substring(end)
      textarea.value = newValue
      // Select "url" for easy replacement
      const urlStart = start + 9 // length of '<a href="'
      textarea.setSelectionRange(urlStart, urlStart + 3)
    } else {
      // Insert link template
      const linkText = '<a href="url" class="text-blue-600 underline">link text</a>'
      const newValue = value.substring(0, start) + linkText + value.substring(end)
      textarea.value = newValue
      // Select "url" for easy replacement
      textarea.setSelectionRange(start + 9, start + 12)
    }

    textarea.focus()
    textarea.dispatchEvent(new Event('input', { bubbles: true }))
  }

  wrapListItem(openList, closeList, openItem, closeItem) {
    const textarea = this.textareaTarget
    const start = textarea.selectionStart
    const end = textarea.selectionEnd
    const value = textarea.value
    const selectedText = value.substring(start, end)

    if (selectedText) {
      // Split selected text by lines and wrap each in <li>
      const lines = selectedText.split('\n').filter(line => line.trim())
      const listItems = lines.map(line => `  ${openItem}${line.trim()}${closeItem}`).join('\n')
      const newValue = value.substring(0, start) + openList + '\n' + listItems + '\n' + closeList + value.substring(end)
      textarea.value = newValue
      const newPos = start + openList.length + listItems.length + closeList.length + 2
      textarea.setSelectionRange(newPos, newPos)
    } else {
      // Insert empty list item
      const newValue = value.substring(0, start) + openList + '\n  ' + openItem + closeItem + '\n' + closeList + value.substring(end)
      textarea.value = newValue
      // Position cursor inside the list item
      const newPos = start + openList.length + 3 + openItem.length
      textarea.setSelectionRange(newPos, newPos)
    }

    textarea.focus()
    textarea.dispatchEvent(new Event('input', { bubbles: true }))
  }

  wrapSelection(before, after) {
    const textarea = this.textareaTarget

    // Ensure textarea has focus first
    textarea.focus()

    const start = textarea.selectionStart
    const end = textarea.selectionEnd
    const value = textarea.value
    const selectedText = value.substring(start, end)

    // If no selection, insert markers with cursor between
    if (start === end) {
      const newValue = value.substring(0, start) + before + after + value.substring(end)
      textarea.value = newValue
      const newPos = start + before.length
      textarea.setSelectionRange(newPos, newPos)
    } else {
      // Wrap selected text
      const newValue = value.substring(0, start) + before + selectedText + after + value.substring(end)
      textarea.value = newValue
      textarea.setSelectionRange(start + before.length, end + before.length)
    }

    textarea.dispatchEvent(new Event('input', { bubbles: true }))
  }

  updateCharCount() {
    if (!this.hasCharCountTarget) return

    const length = this.textareaTarget.value.length
    const max = this.maxLengthValue
    const remaining = max - length
    const percent = (length / max) * 100

    this.charCountTarget.textContent = `${length.toLocaleString()} / ${max.toLocaleString()} characters`

    // Change color based on usage
    if (percent >= 95) {
      this.charCountTarget.className = 'text-xs font-medium text-red-600'
    } else if (percent >= 80) {
      this.charCountTarget.className = 'text-xs font-medium text-yellow-600'
    } else {
      this.charCountTarget.className = 'text-xs text-gray-500'
    }

    // Warn if exceeding limit
    if (length > max) {
      alert(`Content is too large (${length.toLocaleString()} characters). Maximum is ${max.toLocaleString()} characters. Please reduce the content size.`)
    }
  }
}
