import { Controller } from "@hotwired/stimulus";

// Handles study group interactions like join/leave and form display
export default class extends Controller {
    connect() {
        console.log("Study groups controller connected");
    }

    showForm(event) {
        event.preventDefault();
        // Turbo Frame handles loading the form
        // We can add animations or state changes here
        const formContainer = document.getElementById("new_group_form");
        if (formContainer) {
            formContainer.classList.add("active");
        }
    }

    closeForm(event) {
        event.preventDefault();
        const formContainer = document.getElementById("new_group_form");
        if (formContainer) {
            formContainer.innerHTML = "";
            formContainer.classList.remove("active");
        }
    }

    async join(event) {
        // This is handled by button_to with turbo_stream: true
        // The server responds with Turbo Stream that updates the DOM
        // We can add optimistic UI updates here if needed
        const button = event.target;
        button.disabled = true;
        button.textContent = "Joining...";
    }

    async leave(event) {
        // Similar to join, handled by button_to with turbo_stream
        const button = event.target;
        button.disabled = true;
        button.textContent = "Leaving...";
    }
}
