import { Controller } from "@hotwired/stimulus";

// Handles course card interactions and expanding/collapsing details
export default class extends Controller {
    static targets = ["toggleButton", "buttonText", "frameContent"];
    static values = { expanded: Boolean, courseId: Number };

    connect() {
        console.log("Courses controller connected");

        // Listen for Turbo Frame load completion
        this.frameContentTarget.addEventListener("turbo:frame-load", () => {
            // Check if content was actually loaded
            if (
                this.frameContentTarget.innerHTML.trim() &&
                !this.frameContentTarget.querySelector(".empty-state")
            ) {
                this.expand();
            }
        });
    }

    toggle(event) {
        if (this.expandedValue) {
            // If already expanded, prevent navigation and collapse
            event.preventDefault();
            this.collapse();
        } else {
            // If collapsed, let Turbo Frame handle the request
            // The turbo:frame-load event will trigger expand()
        }
    }

    expand() {
        this.expandedValue = true;
        this.element.classList.add("expanded");
        this.buttonTextTarget.textContent = "Hide Study Groups ↑";
        this.toggleButtonTarget.classList.remove("btn-primary");
        this.toggleButtonTarget.classList.add("btn-secondary");
    }

    collapse() {
        this.expandedValue = false;
        this.frameContentTarget.innerHTML = "";
        this.element.classList.remove("expanded");
        this.buttonTextTarget.textContent = "View Study Groups →";
        this.toggleButtonTarget.classList.remove("btn-secondary");
        this.toggleButtonTarget.classList.add("btn-primary");
    }
}
