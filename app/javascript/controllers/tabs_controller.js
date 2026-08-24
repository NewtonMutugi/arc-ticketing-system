import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static classes = ["activeTab", "inactiveTab"]

  connect() {
    // initialize by showing the first tab if not already set, or just rely on DOM
    this.showTab(0)
  }

  switch(event) {
    event.preventDefault()
    const index = this.tabTargets.indexOf(event.currentTarget)
    this.showTab(index)
  }

  showTab(index) {
    this.panelTargets.forEach((panel, i) => {
      if (i === index) {
        panel.classList.remove("hidden")
      } else {
        panel.classList.add("hidden")
      }
    })

    this.tabTargets.forEach((tab, i) => {
      if (i === index) {
        tab.classList.add(...this.activeTabClasses)
        tab.classList.remove(...this.inactiveTabClasses)
      } else {
        tab.classList.remove(...this.activeTabClasses)
        tab.classList.add(...this.inactiveTabClasses)
      }
    })
  }
}
