import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="password-visibility"
export default class extends Controller {
  static targets = ["input", "open", "closed"]

  toggle(e) {
    e.preventDefault()
    
    if (this.inputTarget.type === "password") {
      this.inputTarget.type = "text"
      this.openTarget.classList.add("hidden")
      this.closedTarget.classList.remove("hidden")
    } else {
      this.inputTarget.type = "password"
      this.openTarget.classList.remove("hidden")
      this.closedTarget.classList.add("hidden")
    }
  }
}
