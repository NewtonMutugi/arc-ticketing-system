import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["provider", "referenceContainer", "referenceInput"]

  connect() {
    this.toggle()
  }

  toggle() {
    if (!this.hasProviderTarget || !this.hasReferenceContainerTarget) return
    
    const provider = this.providerTarget.value
    if (provider === "M-Pesa") {
      this.referenceContainerTarget.classList.remove("hidden")
      if (this.hasReferenceInputTarget) {
        this.referenceInputTarget.required = true
      }
    } else {
      this.referenceContainerTarget.classList.add("hidden")
      if (this.hasReferenceInputTarget) {
        this.referenceInputTarget.required = false
        this.referenceInputTarget.value = ""
      }
    }
  }
}
