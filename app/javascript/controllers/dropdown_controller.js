import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["menu"]

    connect() {
        // Close on resize to update position/avoid misalignment
        this.resizeObserver = new ResizeObserver(() => this.hide(null))
        this.resizeObserver.observe(document.body)
    }

    disconnect() {
        if (this.resizeObserver) this.resizeObserver.disconnect()
    }

    toggle() {
        if (this.menuTarget.classList.contains("hidden")) {
            this.show()
        } else {
            this.hide(null)
        }
    }

    show() {
        this.menuTarget.classList.remove("hidden")
        this.updatePosition()
    }

    hide(event) {
        if (event && this.element.contains(event.target)) return
        this.menuTarget.classList.add("hidden")
    }

    updatePosition() {
        const triggerRect = this.element.getBoundingClientRect()
        const menuRect = this.menuTarget.getBoundingClientRect()

        // Use fixed positioning to escape overflow containers
        this.menuTarget.style.position = 'fixed'
        this.menuTarget.style.zIndex = '9999'

        // Position: Bottom-Left aligned with trigger
        // Calculate bottom space: Viewport Height - Trigger Top
        // We want the bottom of the menu to be at (Trigger Top - margin)

        const margin = 8 // mb-2 approx
        const bottom = window.innerHeight - triggerRect.top + margin

        this.menuTarget.style.bottom = `${bottom}px`
        this.menuTarget.style.left = `${triggerRect.left}px`
        this.menuTarget.style.top = 'auto'
        this.menuTarget.style.right = 'auto'

        // Ensure consistent width (default w-56 is 14rem = 224px)
        this.menuTarget.style.width = '14rem'
    }
}
