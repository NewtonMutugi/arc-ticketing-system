import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "ticket", "quantity", "total" ]

  connect() {
    // Optionally calculate on load if pre-selected, but total should ideally be blank by default for override
  }

  updatePrice() {
    const ticketSelect = this.ticketTarget
    const quantity = parseInt(this.quantityTarget.value) || 1
    
    // Get the selected option
    const selectedOption = ticketSelect.options[ticketSelect.selectedIndex]
    
    if (selectedOption && selectedOption.dataset.price) {
      const price = parseFloat(selectedOption.dataset.price)
      const total = price * quantity
      
      // We only update if they haven't manually typed an override, 
      // or if they change the ticket/quantity, we just reset it to the new calculated price to be helpful
      this.totalTarget.value = total.toFixed(2)
    } else {
      this.totalTarget.value = ""
    }
  }
}
