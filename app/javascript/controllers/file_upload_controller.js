import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "preview", "prompt"]

    connect() {
        this.handlePreview()
    }

    preview() {
        this.handlePreview()
    }

    handlePreview() {
        const input = this.inputTarget
        const preview = this.previewTarget
        const prompt = this.promptTarget

        if (input.files && input.files[0]) {
            const reader = new FileReader()

            reader.onload = (e) => {
                preview.src = e.target.result
                preview.classList.remove("hidden")
                prompt.classList.add("hidden")
            }

            reader.readAsDataURL(input.files[0])
        } else {
            // Handle case where no file is selected but we might have an existing image
            // Check if the preview source is not empty/null
            if (preview.src && preview.src !== "" && !preview.src.endsWith(window.location.href)) {
                preview.classList.remove("hidden")
                prompt.classList.add("hidden")
            } else {
                preview.classList.add("hidden")
                prompt.classList.remove("hidden")
            }

        }
    }
}
