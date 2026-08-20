import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    datetime: String,
    format: { type: String, default: 'datetime' } // 'datetime', 'date', 'time'
  }

  connect() {
    if (!this.hasDatetimeValue) return

    const date = new Date(this.datetimeValue)
    
    let options = {}
    
    if (this.formatValue === 'date') {
      options = { month: 'short', day: 'numeric', year: 'numeric' }
    } else if (this.formatValue === 'time') {
      options = { hour: '2-digit', minute: '2-digit' }
    } else {
      options = { month: 'short', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit' }
    }

    this.element.textContent = date.toLocaleString(undefined, options)
    this.element.title = date.toLocaleString()
  }
}
