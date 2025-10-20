import { Controller } from "@hotwired/stimulus";

// Handles flash message display and dismissal
export default class extends Controller {
    connect() {
        // Auto-dismiss after 5 seconds
        this.timeout = setTimeout(() => {
            this.dismiss();
        }, 5000);
    }

    disconnect() {
        if (this.timeout) {
            clearTimeout(this.timeout);
        }
    }

    dismiss() {
        this.element.classList.add("dismissing");

        // Wait for animation to complete
        setTimeout(() => {
            this.element.remove();
        }, 300);
    }
}
