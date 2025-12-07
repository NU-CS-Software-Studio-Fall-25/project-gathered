import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  preview(event) {
    const color = event.target.value
    // Update the preview avatar on the edit page
    const avatarPreview = document.getElementById('avatar-preview')
    if (avatarPreview) {
      avatarPreview.style.backgroundColor = color
    }
    // Also update the navbar avatar
    const navbarAvatar = document.getElementById('navbar-avatar')
    if (navbarAvatar) {
      navbarAvatar.style.backgroundColor = color
    }
  }

  save(event) {
    const color = event.target.value
    
    fetch('/student/update_avatar_color', {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ avatar_color: color })
    }).catch(error => {
      console.error('Failed to save avatar color:', error)
    })
  }
}
