import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        console.log("Toast controller connected!") // Check your browser console for this

        setTimeout(() => {
            this.element.classList.add("transition-all", "duration-500", "opacity-0", "translate-x-full")

            setTimeout(() => {
                this.element.remove()
            }, 500)
        }, 4000)
    }
}
