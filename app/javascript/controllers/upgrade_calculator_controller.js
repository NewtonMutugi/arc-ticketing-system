import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["ticketSelect", "priceDifference", "paymentMethod", "phoneInput", "referenceInput"]
  static values = {
    currentPrice: Number,
    tickets: Array
  }

  connect() {
    this.calculate()
    this.togglePaymentFields()
  }

  calculate() {
    const selectedTicketId = this.ticketSelectTarget.value
    const selectedTicket = this.ticketsValue.find(t => t.id == selectedTicketId)
    
    if (selectedTicket) {
      const difference = Math.max(0, selectedTicket.price - this.currentPriceValue)
      this.priceDifferenceTarget.textContent = new Intl.NumberFormat('en-KE', { 
        style: 'currency', 
        currency: 'KES',
        maximumFractionDigits: 0
      }).format(difference)
    } else {
      this.priceDifferenceTarget.textContent = "Ksh 0"
    }
  }

  togglePaymentFields() {
    const method = this.paymentMethodTarget.value
    if (method === 'stk_push') {
      this.phoneInputTarget.classList.remove('hidden')
      this.referenceInputTarget.classList.add('hidden')
    } else if (method === 'manual') {
      this.phoneInputTarget.classList.add('hidden')
      this.referenceInputTarget.classList.remove('hidden')
    }
  }
}
