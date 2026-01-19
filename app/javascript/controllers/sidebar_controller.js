import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["sidebar", "text", "logo", "collapsedLogo", "openIcon", "closeIcon", "wrapper", "header"]
    static classes = ["collapsed", "expanded"]

    connect() {
        this.ensureState()
    }

    toggle() {
        this.collapsedValue = !this.collapsedValue
        this.updateState()
    }

    ensureState() {
        const storedFunc = localStorage.getItem("sidebarCollapsed")
        this.collapsedValue = storedFunc === "true"
        this.updateState()
    }

    updateState() {
        if (this.collapsedValue) {
            this.sidebarTarget.classList.remove("w-64")
            this.sidebarTarget.classList.add("w-20")

            // Adjust wrapper padding to prevent overflow
            if (this.hasWrapperTarget) {
                this.wrapperTarget.classList.remove("px-4")
                this.wrapperTarget.classList.add("px-2")
            }

            // Stack header items vertically to fit in narrow width
            if (this.hasHeaderTarget) {
                this.headerTarget.classList.remove("flex-row", "justify-between")
                this.headerTarget.classList.add("flex-col", "gap-4")
            }

            this.textTargets.forEach(t => t.classList.add("hidden"))
            if (this.hasCollapsedLogoTarget) this.collapsedLogoTarget.classList.remove("hidden")
            if (this.hasOpenIconTarget) this.openIconTarget.classList.remove("hidden")
            if (this.hasCloseIconTarget) this.closeIconTarget.classList.add("hidden")
            localStorage.setItem("sidebarCollapsed", "true")
        } else {
            this.sidebarTarget.classList.remove("w-20")
            this.sidebarTarget.classList.add("w-64")

            // Restore wrapper padding
            if (this.hasWrapperTarget) {
                this.wrapperTarget.classList.remove("px-2")
                this.wrapperTarget.classList.add("px-4")
            }

            // Restore header layout
            if (this.hasHeaderTarget) {
                this.headerTarget.classList.remove("flex-col", "gap-4")
                this.headerTarget.classList.add("flex-row", "justify-between")
            }

            this.textTargets.forEach(t => t.classList.remove("hidden"))
            if (this.hasCollapsedLogoTarget) this.collapsedLogoTarget.classList.add("hidden")
            if (this.hasOpenIconTarget) this.openIconTarget.classList.add("hidden")
            if (this.hasCloseIconTarget) this.closeIconTarget.classList.remove("hidden")
            localStorage.setItem("sidebarCollapsed", "false")
        }
    }
}
