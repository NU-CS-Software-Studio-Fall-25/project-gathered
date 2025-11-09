import { Controller } from "@hotwired/stimulus";

const REQUIREMENTS = {
	length: (value) => value.length >= 8,
	lowercase: (value) => /[a-z]/.test(value),
	uppercase: (value) => /[A-Z]/.test(value),
	nonAlpha: (value) => /[^A-Za-z]/.test(value),
};

export default class extends Controller {
	static targets = [
		"form",
		"email",
		"password",
		"confirmation",
		"passwordMessage",
		"confirmationMessage",
		"formMessage",
		"capsLockIndicator",
		"submit",
		"requirements",
		"requirementsList",
		"requirementsCheck",
	];

	connect() {
		this.emailValid = false;
		this.passwordValid = false;
		this.confirmationValid = false;
		this.passwordCheckShown = false; // Track if checkmark is already showing
		this.formTarget.setAttribute("novalidate", "novalidate");
		this.requirementItems = this.requirementsTarget.querySelectorAll(
			"[data-signup-requirement]"
		);
		this.resetRequirements();
		this.setSubmitState();
	}

	validateEmail(event = null) {
		if (!this.hasEmailTarget) return;
		const value = this.emailTarget.value;
		const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
		
		if (!value) {
			this.emailValid = false;
			this.setFieldBorder(this.emailTarget, null);
			this.setSubmitState();
			return;
		}

		const isValid = emailRegex.test(value);
		this.emailValid = isValid;
		this.setFieldBorder(this.emailTarget, isValid ? null : false);
		this.setSubmitState();
	}

	validatePassword(event = null) {
		const value = this.passwordTarget.value;
		const isInputEvent = event?.type === "input";

		if (!value) {
			this.resetRequirements();
			this.passwordValid = false;
			this.setFieldBorder(this.passwordTarget, null);
			this.showRequirementsList();
			this.setSubmitState();
			return;
		}

		let allValid = true;
		for (const [key, check] of Object.entries(REQUIREMENTS)) {
			const satisfied = check(value);
			allValid = allValid && satisfied;
			this.updateRequirementState(key, satisfied);
		}

		if (!allValid) {
			this.passwordValid = false;
			this.setFieldBorder(this.passwordTarget, false);
			this.showRequirementsList();
			this.setSubmitState();
			return;
		}

		this.passwordValid = true;
		this.setFieldBorder(this.passwordTarget, true);
		
		// Only show animation if transitioning from invalid to valid
		if (!this.passwordCheckShown) {
			this.showRequirementsCheck();
		}
		
		this.validateConfirmation();
		this.setSubmitState();
	}

	validateConfirmation(event = null) {
		if (!this.hasConfirmationTarget) return;
		const value = this.confirmationTarget.value;
		const isInputEvent = event?.type === "input";

		if (!value) {
			this.confirmationValid = false;
			this.setFieldBorder(this.confirmationTarget, null);
			this.setSubmitState();
			return;
		}

		if (value !== this.passwordTarget.value) {
			this.confirmationValid = false;
			this.setFieldBorder(this.confirmationTarget, false);
			this.setSubmitState();
			return;
		}

		this.confirmationValid = true;
		this.setFieldBorder(this.confirmationTarget, true);
		this.setSubmitState();
	}

	detectCapsLock(event) {
		if (!this.hasCapsLockIndicatorTarget) return;
		const isOn =
			event.getModifierState && event.getModifierState("CapsLock");
		this.capsLockIndicatorTarget.textContent = isOn
			? "Caps Lock is on"
			: "";
	}

	handleSubmit(event) {
		this.validateEmail();
		this.validatePassword();
		this.validateConfirmation();

		if (!this.emailValid || !this.passwordValid || !this.confirmationValid) {
			event.preventDefault();
			this.setFormFeedback(
				"Take another look — fix the errors above to continue.",
				false
			);
			return;
		}

		this.setFormFeedback("Creating your account…", true);
		if (this.hasSubmitTarget) {
			this.submitTarget.disabled = true;
			this.submitTarget.setAttribute("aria-disabled", "true");
		}
	}

	setPasswordFeedback(message, state) {
		this.updateFeedback(this.passwordMessageTarget, message, state);
	}

	setConfirmationFeedback(message, state) {
		this.updateFeedback(this.confirmationMessageTarget, message, state);
	}

	setFormFeedback(message, state) {
		if (!this.hasFormMessageTarget) return;
		this.updateFeedback(this.formMessageTarget, message, state);
	}

	setSubmitState() {
		if (!this.hasSubmitTarget) return;
		const ready = this.emailValid && this.passwordValid && this.confirmationValid;
		this.submitTarget.disabled = !ready;
		this.submitTarget.setAttribute("aria-disabled", String(!ready));
	}

	setFieldBorder(field, isValid) {
		if (!field) return;
		
		// Remove all border classes
		field.classList.remove(
			"border-white/20",
			"border-red-500/50",
			"border-emerald-500/50"
		);
		
		// Add appropriate border class
		if (isValid === true) {
			field.classList.add("border-emerald-500/50");
		} else if (isValid === false) {
			field.classList.add("border-red-500/50");
		} else {
			field.classList.add("border-white/20");
		}
	}

	resetRequirements() {
		this.requirementItems?.forEach((item) => {
			this.applyRequirementState(item, "neutral");
		});
	}

	updateRequirementState(name, satisfied) {
		if (!this.requirementItems) return;
		this.requirementItems.forEach((item) => {
			if (item.dataset.signupRequirement !== name) return;
			this.applyRequirementState(item, satisfied ? "valid" : "invalid");
		});
	}

	applyRequirementState(item, state) {
		const box = item.querySelector("span");
		
		if (!box) return;

		// Remove all state classes
		box.classList.remove(
			"border-emerald-500/50",
			"border-rose-500/50",
			"border-violet-300/50",
			"bg-emerald-500/20",
			"bg-rose-500/20",
			"bg-violet-300/20",
			"text-emerald-200",
			"text-rose-200",
			"text-violet-100"
		);

		// Apply classes based on state
		if (state === "valid") {
			box.classList.add("border-emerald-500/50", "bg-emerald-500/20", "text-emerald-200");
		} else if (state === "invalid") {
			box.classList.add("border-rose-500/50", "bg-rose-500/20", "text-rose-200");
		} else {
			box.classList.add("border-violet-300/50", "bg-violet-300/20", "text-violet-100");
		}
	}

	showRequirementsList() {
		if (!this.hasRequirementsListTarget || !this.hasRequirementsCheckTarget) return;
		
		this.passwordCheckShown = false; // Reset flag when showing list
		this.requirementsListTarget.classList.remove("opacity-0");
		this.requirementsListTarget.classList.add("opacity-100");
		this.requirementsCheckTarget.classList.remove("opacity-100");
		this.requirementsCheckTarget.classList.add("opacity-0");
	}

	showRequirementsCheck() {
		if (!this.hasRequirementsListTarget || !this.hasRequirementsCheckTarget) return;
		
		this.passwordCheckShown = true; // Mark that checkmark is now shown
		this.requirementsListTarget.classList.remove("opacity-100");
		this.requirementsListTarget.classList.add("opacity-0");
		this.requirementsCheckTarget.classList.remove("opacity-0");
		this.requirementsCheckTarget.classList.add("opacity-100", "checkmark-animate");
		
		// Trigger shine animation after fade completes
		setTimeout(() => {
			this.requirementsTarget.classList.add("shine-once");
			// Remove the class after animation completes so it can be triggered again
			setTimeout(() => {
				this.requirementsTarget.classList.remove("shine-once");
			}, 1500);
		}, 500);
		
		// Remove checkmark animation class after it completes
		setTimeout(() => {
			this.requirementsCheckTarget.classList.remove("checkmark-animate");
		}, 500);
	}

	updateFeedback(target, message, state) {
		if (!target) return;
		const neutralClass = "text-violet-100";

		if (!message) {
			target.textContent = "";
			target.classList.remove(
				"text-emerald-200",
				"text-rose-200",
				"text-emerald-300",
				"text-rose-300",
				"text-slate-300"
			);
			if (!target.classList.contains(neutralClass))
				target.classList.add(neutralClass);
			return;
		}

		const isPositive = state === true;
		const isNegative = state === false;

		target.textContent = message;
		target.classList.remove(
			"text-emerald-300",
			"text-rose-300",
			"text-slate-300"
		);
		target.classList.toggle("text-emerald-200", isPositive);
		target.classList.toggle("text-rose-200", isNegative);

		if (!isPositive && !isNegative) {
			target.classList.add(neutralClass);
		} else {
			target.classList.remove(neutralClass);
		}
	}
}
