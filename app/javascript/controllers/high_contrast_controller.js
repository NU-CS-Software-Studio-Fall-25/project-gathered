import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle(event) {
    const isEnabled = event.target.checked
    
    // Immediately toggle the class on the body for instant feedback
    document.body.classList.toggle('high-contrast', isEnabled)
    
    // Save to server
    fetch('/student/toggle_high_contrast', {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ high_contrast: isEnabled })
    }).catch(error => {
      console.error('Failed to save high contrast preference:', error)
      // Revert on error
      document.body.classList.toggle('high-contrast', !isEnabled)
      event.target.checked = !isEnabled
    })
  }
}
