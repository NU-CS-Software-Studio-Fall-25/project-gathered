import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["name", "email", "password", "passwordConfirmation"]
  static classes = ["error", "valid"]

  connect() {
    this.validateOnBlur()
  }

  validateOnBlur() {
    this.nameTarget.addEventListener('blur', () => this.validateName())
    this.emailTarget.addEventListener('blur', () => this.validateEmail())
    this.passwordTarget.addEventListener('blur', () => this.validatePassword())
    this.passwordConfirmationTarget.addEventListener('blur', () => this.validatePasswordConfirmation())
  }

  validateName() {
    const name = this.nameTarget.value.trim()
    if (name.length === 0) {
      this.showError(this.nameTarget, "Please enter your name")
    } else if (name.length > 100) {
      this.showError(this.nameTarget, "Name is too long (maximum is 100 characters)")
    } else {
      this.hideError(this.nameTarget)
    }
  }

  validateEmail() {
    const email = this.emailTarget.value.trim()
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    
    if (email.length === 0) {
      this.showError(this.emailTarget, "Please enter your email address")
    } else if (!emailRegex.test(email)) {
      this.showError(this.emailTarget, "Please enter a valid email address")
    } else {
      this.hideError(this.emailTarget)
    }
  }

  validatePassword() {
    const password = this.passwordTarget.value
    if (password.length === 0) {
      this.showError(this.passwordTarget, "Please enter a password")
    } else if (password.length < 6) {
      this.showError(this.passwordTarget, "Password must be at least 6 characters")
    } else {
      this.hideError(this.passwordTarget)
    }
    // Also validate confirmation if it has a value
    if (this.passwordConfirmationTarget.value) {
      this.validatePasswordConfirmation()
    }
  }

  validatePasswordConfirmation() {
    const password = this.passwordTarget.value
    const confirmation = this.passwordConfirmationTarget.value
    
    if (confirmation.length === 0) {
      this.showError(this.passwordConfirmationTarget, "Please confirm your password")
    } else if (password !== confirmation) {
      this.showError(this.passwordConfirmationTarget, "Passwords don't match")
    } else {
      this.hideError(this.passwordConfirmationTarget)
    }
  }

  showError(element, message) {
    const errorDiv = this.findOrCreateErrorDiv(element)
    element.classList.add("border-rose-400/50")
    element.classList.add("focus:ring-rose-400/50")
    element.classList.remove("border-white/20")
    element.classList.remove("focus:ring-violet-400/70")
    errorDiv.textContent = message
    errorDiv.classList.remove("hidden")
  }

  hideError(element) {
    const errorDiv = this.findOrCreateErrorDiv(element)
    element.classList.remove("border-rose-400/50")
    element.classList.remove("focus:ring-rose-400/50")
    element.classList.add("border-white/20")
    element.classList.add("focus:ring-violet-400/70")
    errorDiv.classList.add("hidden")
  }

  findOrCreateErrorDiv(element) {
    const existingError = element.parentElement.querySelector('[data-error]')
    if (existingError) return existingError
    
    const errorDiv = document.createElement('div')
    errorDiv.setAttribute('data-error', '')
    errorDiv.classList.add(
      "absolute", "left-full", "ml-3", "top-0", "whitespace-nowrap", 
      "rounded", "border", "border-rose-400/70", "bg-white/10", 
      "backdrop-blur-2xl", "shadow-sm", "px-4", "h-[38px]", 
      "flex", "items-center", "text-sm", "text-slate-100"
    )
    element.parentElement.appendChild(errorDiv)
    return errorDiv
  }
}