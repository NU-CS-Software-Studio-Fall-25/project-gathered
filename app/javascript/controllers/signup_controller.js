import { Controller } from "@hotwired/stimulus"

const REQUIREMENTS = {
  length: (value) => value.length >= 8,
  lowercase: (value) => /[a-z]/.test(value),
  uppercase: (value) => /[A-Z]/.test(value),
  nonAlpha: (value) => /[^A-Za-z]/.test(value)
}

export default class extends Controller {
  static targets = [
    "form",
    "password",
    "confirmation",
    "passwordMessage",
    "confirmationMessage",
    "formMessage",
    "capsLockIndicator",
    "submit",
    "requirements"
  ]

  connect() {
    this.passwordValid = false
    this.confirmationValid = false
    this.formTarget.setAttribute("novalidate", "novalidate")
    this.requirementItems = this.requirementsTarget.querySelectorAll("[data-signup-requirement]")
    this.resetRequirements()
    this.setSubmitState()
  }

  validatePassword(event = null) {
    const value = this.passwordTarget.value
    const isInputEvent = event?.type === "input"

    if (!value) {
      this.resetRequirements()
      this.setPasswordFeedback(isInputEvent ? "" : "Create a password that meets the rules above.", isInputEvent ? null : false)
      this.passwordValid = false
      this.setSubmitState()
      return
    }

    let allValid = true
    for (const [key, check] of Object.entries(REQUIREMENTS)) {
      const satisfied = check(value)
      allValid = allValid && satisfied
      this.updateRequirementState(key, satisfied)
    }

    if (!allValid) {
      this.setPasswordFeedback("Almost there — meet each rule to continue.", false)
      this.passwordValid = false
      this.setSubmitState()
      return
    }

    this.setPasswordFeedback("Great! Your password checks every box.", true)
    this.passwordValid = true
    this.validateConfirmation()
    this.setSubmitState()
  }

  validateConfirmation(event = null) {
    if (!this.hasConfirmationTarget) return
    const value = this.confirmationTarget.value
    const isInputEvent = event?.type === "input"

    if (!value) {
      this.setConfirmationFeedback(isInputEvent ? "" : "Confirm your password so we know it matches.", isInputEvent ? null : false)
      this.confirmationValid = false
      this.setSubmitState()
      return
    }

    if (value !== this.passwordTarget.value) {
      this.setConfirmationFeedback("Passwords need to match exactly.", false)
      this.confirmationValid = false
      this.setSubmitState()
      return
    }

    this.setConfirmationFeedback("Passwords match — nice!", true)
    this.confirmationValid = true
    this.setSubmitState()
  }

  detectCapsLock(event) {
    if (!this.hasCapsLockIndicatorTarget) return
    const isOn = event.getModifierState && event.getModifierState("CapsLock")
    this.capsLockIndicatorTarget.textContent = isOn ? "Caps Lock is on" : ""
  }

  handleSubmit(event) {
    this.validatePassword()
    this.validateConfirmation()

    if (!this.passwordValid || !this.confirmationValid) {
      event.preventDefault()
      this.setFormFeedback("Take another look — your password needs to meet every rule.", false)
      return
    }

    this.setFormFeedback("Creating your account…", true)
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = true
      this.submitTarget.setAttribute("aria-disabled", "true")
    }
  }

  setPasswordFeedback(message, state) {
    this.updateFeedback(this.passwordMessageTarget, message, state)
  }

  setConfirmationFeedback(message, state) {
    this.updateFeedback(this.confirmationMessageTarget, message, state)
  }

  setFormFeedback(message, state) {
    if (!this.hasFormMessageTarget) return
    this.updateFeedback(this.formMessageTarget, message, state)
  }

  setSubmitState() {
    if (!this.hasSubmitTarget) return
    const ready = this.passwordValid && this.confirmationValid
    this.submitTarget.disabled = !ready
    this.submitTarget.setAttribute("aria-disabled", String(!ready))
  }

  resetRequirements() {
    this.requirementItems?.forEach((item) => {
      this.applyRequirementState(item, "neutral")
    })
  }

  updateRequirementState(name, satisfied) {
    if (!this.requirementItems) return
    this.requirementItems.forEach((item) => {
      if (item.dataset.signupRequirement !== name) return
      this.applyRequirementState(item, satisfied ? "valid" : "invalid")
    })
  }

  applyRequirementState(item, state) {
    const dot = item.querySelector("span")
    item.classList.remove("text-emerald-200", "text-rose-200", "text-violet-100", "text-slate-300", "text-emerald-300", "text-rose-300")

    let textClass = "text-violet-100"
    let dotClass = "bg-violet-300"

    if (state === "valid") {
      textClass = "text-emerald-200"
      dotClass = "bg-emerald-300"
    } else if (state === "invalid") {
      textClass = "text-rose-200"
      dotClass = "bg-rose-300"
    }

    item.classList.add(textClass)
    if (dot) {
      dot.classList.remove("bg-emerald-300", "bg-rose-300", "bg-violet-300", "bg-slate-300")
      dot.classList.add(dotClass)
    }
  }

  updateFeedback(target, message, state) {
    if (!target) return
    const neutralClass = "text-violet-100"

    if (!message) {
      target.textContent = ""
      target.classList.remove("text-emerald-200", "text-rose-200", "text-emerald-300", "text-rose-300", "text-slate-300")
      if (!target.classList.contains(neutralClass)) target.classList.add(neutralClass)
      return
    }

    const isPositive = state === true
    const isNegative = state === false

    target.textContent = message
    target.classList.remove("text-emerald-300", "text-rose-300", "text-slate-300")
    target.classList.toggle("text-emerald-200", isPositive)
    target.classList.toggle("text-rose-200", isNegative)

    if (!isPositive && !isNegative) {
      target.classList.add(neutralClass)
    } else {
      target.classList.remove(neutralClass)
    }
  }
}
