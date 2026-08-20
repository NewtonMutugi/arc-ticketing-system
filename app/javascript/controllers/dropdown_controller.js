import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["menu"]
    static values = {
        direction: { type: String, default: "up" },
        align: { type: String, default: "right" }
    }

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
        const margin = 8 // margin approx

        // Use fixed positioning to escape overflow containers
        this.menuTarget.style.position = 'fixed'
        this.menuTarget.style.zIndex = '9999'

        // Determine vertical placement
        if (this.directionValue === "down") {
            this.menuTarget.style.top = `${triggerRect.bottom + margin}px`
            this.menuTarget.style.bottom = 'auto'
        } else {
            const bottom = window.innerHeight - triggerRect.top + margin
            this.menuTarget.style.bottom = `${bottom}px`
            this.menuTarget.style.top = 'auto'
        }

        // Determine horizontal placement
        // Default w-56 is 14rem = 224px.
        this.menuTarget.style.width = '14rem'
        const menuWidth = 224 

        if (this.alignValue === "left") {
            this.menuTarget.style.left = `${triggerRect.left}px`
            this.menuTarget.style.right = 'auto'
        } else {
            this.menuTarget.style.right = `${window.innerWidth - triggerRect.right}px`
            this.menuTarget.style.left = 'auto'
        }
    }
}
