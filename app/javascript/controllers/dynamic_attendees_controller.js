import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template", "quantity", "ticket"]

  connect() {
    this.updateFields()
  }

  updateFields() {
    if (!this.hasQuantityTarget || !this.hasContainerTarget) return
    
    const quantity = parseInt(this.quantityTarget.value) || 1
    
    // We get the selected ticket's hashid or id if possible. 
    // In the public flow it uses hashid, but in the admin panel ticket.id works for relationships, 
    // although our attendees mapping in public uses hashid. Admin controller uses ticket.id mostly.
    const ticketId = this.hasTicketTarget ? this.ticketTarget.value : ""

    const currentBlocks = this.containerTarget.children.length

    if (quantity > currentBlocks) {
      for (let i = currentBlocks; i < quantity; i++) {
        this.addBlock(i, ticketId)
      }
    } else if (quantity < currentBlocks) {
      for (let i = currentBlocks - 1; i >= quantity; i--) {
        this.containerTarget.children[i].remove()
      }
    }

    if (this.hasTicketTarget) {
      const ticketInputs = this.containerTarget.querySelectorAll('input[name="attendees[][ticket_id]"]')
      ticketInputs.forEach(input => input.value = ticketId)
    }
  }

  addBlock(index, ticketId) {
    if (!this.hasTemplateTarget) return
    const content = this.templateTarget.innerHTML
      .replace(/INDEX/g, index + 1)
      .replace(/TICKET_ID_PLACEHOLDER/g, ticketId)
    
    this.containerTarget.insertAdjacentHTML('beforeend', content)
  }

  copyBuyerDetails(event) {
    if (!this.hasContainerTarget) return
    
    const firstBlock = this.containerTarget.children[0]
    if (!firstBlock) return

    const firstNameInput = firstBlock.querySelector('input[name="attendees[][first_name]"]')
    const lastNameInput = firstBlock.querySelector('input[name="attendees[][last_name]"]')
    const emailInput = firstBlock.querySelector('input[name="attendees[][email]"]')

    const buyerNameInput = document.querySelector('input[name="order[buyer_name]"]')
    const buyerEmailInput = document.querySelector('input[name="order[buyer_email]"]')

    if (event.target.checked) {
      if (buyerNameInput && buyerNameInput.value) {
        const parts = buyerNameInput.value.split(' ')
        if (firstNameInput) firstNameInput.value = parts[0] || ""
        if (lastNameInput) lastNameInput.value = parts.slice(1).join(' ') || ""
      }
      if (buyerEmailInput && buyerEmailInput.value) {
        if (emailInput) emailInput.value = buyerEmailInput.value
      }
    } else {
      if (firstNameInput) firstNameInput.value = ""
      if (lastNameInput) lastNameInput.value = ""
      if (emailInput) emailInput.value = ""
    }
  }
}
