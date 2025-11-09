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
        const formFrame = document.getElementById("new_group_form");
        if (formFrame) {
            // Get the course ID from the URL or a data attribute
            const courseId = this.getCourseIdFromContext();
            if (courseId) {
                // Fetch and restore the create button
                fetch(`/courses/${courseId}/study_groups/new?restore_button=true`)
                    .then(response => response.text())
                    .then(html => {
                        formFrame.innerHTML = html;
                    })
                    .catch(() => {
                        // Fallback: just clear the form
                        formFrame.innerHTML = "";
                    });
            } else {
                formFrame.innerHTML = "";
            }
            formFrame.classList.remove("active");
        }
    }

    getCourseIdFromContext() {
        // Try to get course ID from the form URL or hidden field
        const form = document.querySelector('#new_group_form form');
        if (form) {
            const actionUrl = form.action;
            const match = actionUrl.match(/\/courses\/(\d+)\//);
            if (match) {
                return match[1];
            }
        }
        
        // Try to get from currently selected course
        const selectedCourse = document.querySelector('.course-item[data-selected="true"]');
        if (selectedCourse) {
            return selectedCourse.getAttribute('data-course-id');
        }
        
        return null;
    }

    async join(event) {
        // This is handled by button_to with turbo_stream: true
        // The server responds with Turbo Stream that updates the DOM
        // We can add optimistic UI updates here if needed
        const button = event.target;
        button.disabled = true;
        button.textContent = "Joining...";
    }

    confirmLeave(event) {
        // Just proceed with leaving, no confirmation needed
        const button = event.currentTarget;
        button.disabled = true;
        
        // Find and hide the span with "Joined" text
        const joinedSpan = button.nextElementSibling;
        if (joinedSpan) {
            joinedSpan.style.display = 'none';
        }

        // Store original button content
        const originalContent = button.innerHTML;
        
        // Update button text and add loading animation
        button.innerHTML = `
            <svg class="animate-spin -ml-1 mr-2 h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            Leaving...
        `;

        // If the request takes too long (more than 5 seconds), reset the button
        const timeout = setTimeout(() => {
            button.disabled = false;
            button.innerHTML = originalContent;
            if (joinedSpan) {
                joinedSpan.style.display = '';
            }
            alert('The request is taking longer than expected. Please try again.');
        }, 5000);

        // Clear the timeout when the Turbo response is received
        document.addEventListener('turbo:render', function clearTimeout() {
            clearTimeout(timeout);
            document.removeEventListener('turbo:render', clearTimeout);
        });
    }
}
