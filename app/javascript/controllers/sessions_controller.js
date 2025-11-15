import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["password", "toggleButton", "eyeIcon", "eyeSlashIcon"]

  connect() {
    this.updateUI()
  }

  togglePasswordVisibility() {
    if (!this.hasPasswordTarget) return

    const input = this.passwordTarget
    const isHidden = input.type === "password"
    input.type = isHidden ? "text" : "password"

    this.updateUI()
  }

  updateUI() {
    const showPassword = this.passwordTarget?.type === "text"

    if (this.hasEyeIconTarget) {
      this.eyeIconTarget.classList.toggle("hidden", showPassword)
    }

    if (this.hasEyeSlashIconTarget) {
      this.eyeSlashIconTarget.classList.toggle("hidden", !showPassword)
    }

    if (this.hasToggleButtonTarget) {
      this.toggleButtonTarget.setAttribute("aria-pressed", showPassword ? "true" : "false")
      this.toggleButtonTarget.setAttribute("aria-label", showPassword ? "Hide password" : "Show password")
    }
  }
}

