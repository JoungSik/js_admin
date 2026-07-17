import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    timeout: { type: Number, default: 4000 }
  }

  connect() {
    this.timeoutId = window.setTimeout(() => this.dismiss(), this.timeoutValue)
  }

  disconnect() {
    window.clearTimeout(this.timeoutId)
  }

  dismiss() {
    this.element.classList.add("opacity-0", "translate-y-1")

    window.setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
