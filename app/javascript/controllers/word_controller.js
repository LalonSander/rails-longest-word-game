import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "button", "feedback"]

  async validate() {
    const word = this.inputTarget.value
    this.feedbackTarget.textContent = ""

    if (word.length === 0) {
      this.buttonTarget.disabled = true
      return
    }

    const response = await fetch(`/validate?word=${word}`)
    const data = await response.json()

    if (!data.grid) {
      this.feedbackTarget.textContent = "❌ Not in grid"
      this.buttonTarget.disabled = true
    } else if (!data.dictionary) {
      this.feedbackTarget.textContent = "❌ Not in dictionary"
      this.buttonTarget.disabled = true
    } else {
      this.feedbackTarget.textContent = "✔ Valid word!"
      this.buttonTarget.disabled = false
    }
  }
}
