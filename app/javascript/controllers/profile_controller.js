import { Controller } from "@hotwired/stimulus";

const REQUIREMENTS = {
	length: (value) => value.length >= 8,
	lowercase: (value) => /[a-z]/.test(value),
	uppercase: (value) => /[A-Z]/.test(value),
	nonAlpha: (value) => /[^A-Za-z]/.test(value),
};

export default class extends Controller {
	static targets = [
		"currentPassword",
		"passwordSection",
		"passwordContent",
		"password",
		"confirmation",
		"requirements",
		"requirementsList",
		"requirementsCheck",
		"toggleCurrentButton",
		"eyeCurrentIcon",
		"eyeSlashCurrentIcon",
		"toggleButton",
		"eyeIcon",
		"eyeSlashIcon",
		"toggleConfirmationButton",
		"eyeConfirmationIcon",
		"eyeSlashConfirmationIcon",
		"currentPasswordStatus",
		// Avatar targets
		"colorTab",
		"imageTab",
		"colorPanel",
		"imagePanel",
		"colorInput",
		"fileInput",
		"selectedFileInfo",
		"selectedFilePreview",
		"selectedFileName",
		"fileTypeError",
		"removeAvatarField",
		"avatarColorPreview",
	];

	connect() {
		this.passwordValid = false;
		this.confirmationValid = false;
		this.passwordCheckShown = false;
		this.currentPasswordVisible = false;
		this.passwordVisible = false;
		this.confirmationVisible = false;
		this.currentPasswordVerified = false;
		this.verifyTimeout = null;
		this.activeAvatarTab = "color";
		
		// Initially hide the password section using display none
		if (this.hasPasswordContentTarget) {
			this.passwordContentTarget.style.display = "none";
			this.passwordContentTarget.style.opacity = "0";
		}
		
		this.requirementItems = this.hasRequirementsTarget 
			? this.requirementsTarget.querySelectorAll("[data-profile-requirement]")
			: [];
		this.resetRequirements();

		// Determine initial avatar tab state based on which panel is visible
		if (this.hasImagePanelTarget && !this.imagePanelTarget.classList.contains("hidden")) {
			this.activeAvatarTab = "image";
		}
	}

	checkCurrentPassword() {
		if (!this.hasCurrentPasswordTarget) return;
		
		const value = this.currentPasswordTarget.value;
		
		// Clear any pending verification
		if (this.verifyTimeout) {
			clearTimeout(this.verifyTimeout);
		}
		
		if (value.length === 0) {
			// Hide the password section and clear password fields
			this.hidePasswordSection();
			this.updateCurrentPasswordStatus(null);
			return;
		}
		
		// Show "checking" status
		this.updateCurrentPasswordStatus("checking");
		
		// Debounce the verification call
		this.verifyTimeout = setTimeout(() => {
			this.verifyCurrentPassword(value);
		}, 500);
	}

	async verifyCurrentPassword(password) {
		try {
			const response = await fetch("/student/verify_password", {
				method: "POST",
				headers: {
					"Content-Type": "application/json",
					"X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
				},
				body: JSON.stringify({ password }),
			});
			
			const data = await response.json();
			
			if (data.valid) {
				this.currentPasswordVerified = true;
				this.updateCurrentPasswordStatus("valid");
				this.showPasswordSection();
			} else {
				this.currentPasswordVerified = false;
				this.updateCurrentPasswordStatus("invalid");
				this.hidePasswordSection();
			}
		} catch (error) {
			console.error("Error verifying password:", error);
			this.currentPasswordVerified = false;
			this.updateCurrentPasswordStatus("error");
			this.hidePasswordSection();
		}
	}

	updateCurrentPasswordStatus(status) {
		if (!this.hasCurrentPasswordStatusTarget) return;
		
		const statusEl = this.currentPasswordStatusTarget;
		
		// Remove all status classes
		statusEl.classList.remove("text-slate-400", "text-emerald-400", "text-rose-400");
		
		switch (status) {
			case "checking":
				statusEl.textContent = "Verifying...";
				statusEl.classList.add("text-slate-400");
				break;
			case "valid":
				statusEl.textContent = "✓ Password verified";
				statusEl.classList.add("text-emerald-400");
				break;
			case "invalid":
				statusEl.textContent = "✗ Incorrect password";
				statusEl.classList.add("text-rose-400");
				break;
			case "error":
				statusEl.textContent = "Error verifying password";
				statusEl.classList.add("text-rose-400");
				break;
			default:
				statusEl.textContent = "Enter your current password to change it";
				statusEl.classList.add("text-slate-400");
		}
	}

	showPasswordSection() {
		if (!this.hasPasswordContentTarget) return;
		
		// Show the content first, then animate opacity
		this.passwordContentTarget.style.display = "flex";
		this.passwordContentTarget.style.flexDirection = "column";
		this.passwordContentTarget.style.gap = "0.75rem";
		
		// Trigger reflow to enable animation
		this.passwordContentTarget.offsetHeight;
		
		// Animate opacity
		this.passwordContentTarget.style.transition = "opacity 0.3s ease-out";
		this.passwordContentTarget.style.opacity = "1";
	}

	hidePasswordSection() {
		if (!this.hasPasswordContentTarget) return;
		
		// Animate opacity first
		this.passwordContentTarget.style.transition = "opacity 0.2s ease-out";
		this.passwordContentTarget.style.opacity = "0";
		
		// Then hide after animation
		setTimeout(() => {
			if (this.hasPasswordContentTarget) {
				this.passwordContentTarget.style.display = "none";
			}
		}, 200);
		
		// Clear the password fields
		if (this.hasPasswordTarget) {
			this.passwordTarget.value = "";
			this.setFieldBorder(this.passwordTarget, null);
		}
		if (this.hasConfirmationTarget) {
			this.confirmationTarget.value = "";
			this.setFieldBorder(this.confirmationTarget, null);
		}
		
		// Reset validation state
		this.passwordValid = false;
		this.confirmationValid = false;
		this.currentPasswordVerified = false;
		this.resetRequirements();
		this.showRequirementsList();
	}

	validatePassword(event = null) {
		if (!this.hasPasswordTarget) return;
		
		const value = this.passwordTarget.value;

		if (!value) {
			this.resetRequirements();
			this.passwordValid = false;
			this.setFieldBorder(this.passwordTarget, null);
			this.showRequirementsList();
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
			return;
		}

		this.passwordValid = true;
		this.setFieldBorder(this.passwordTarget, true);
		
		if (!this.passwordCheckShown) {
			this.showRequirementsCheck();
		}
		
		this.validateConfirmation();
	}

	validateConfirmation(event = null) {
		if (!this.hasConfirmationTarget || !this.hasPasswordTarget) return;
		
		const value = this.confirmationTarget.value;

		if (!value) {
			this.confirmationValid = false;
			this.setFieldBorder(this.confirmationTarget, null);
			return;
		}

		if (value !== this.passwordTarget.value) {
			this.confirmationValid = false;
			this.setFieldBorder(this.confirmationTarget, false);
			return;
		}

		this.confirmationValid = true;
		this.setFieldBorder(this.confirmationTarget, true);
	}

	setFieldBorder(field, isValid) {
		if (!field) return;
		
		field.classList.remove(
			"border-white/20",
			"border-red-500/50",
			"border-emerald-500/50"
		);
		
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
			if (item.dataset.profileRequirement !== name) return;
			this.applyRequirementState(item, satisfied ? "valid" : "invalid");
		});
	}

	applyRequirementState(item, state) {
		const requirementName = item.dataset.profileRequirement;
		const checkmark = item.querySelector(`[data-profile-checkmark="${requirementName}"]`);
		const xmark = item.querySelector(`[data-profile-xmark="${requirementName}"]`);
		const text = item.querySelector(`[data-profile-text="${requirementName}"]`);
		
		if (!checkmark || !xmark || !text) return;

		if (state === "valid") {
			checkmark.classList.remove("opacity-0");
			checkmark.classList.add("opacity-100");
			xmark.classList.remove("opacity-100");
			xmark.classList.add("opacity-0");
			text.classList.add("line-through", "opacity-60");
		} else {
			checkmark.classList.remove("opacity-100");
			checkmark.classList.add("opacity-0");
			xmark.classList.remove("opacity-0");
			xmark.classList.add("opacity-100");
			text.classList.remove("line-through", "opacity-60");
		}
	}

	showRequirementsList() {
		if (!this.hasRequirementsListTarget || !this.hasRequirementsCheckTarget) return;
		
		this.passwordCheckShown = false;
		this.requirementsListTarget.classList.remove("opacity-0");
		this.requirementsListTarget.classList.add("opacity-100");
		this.requirementsCheckTarget.classList.remove("opacity-100");
		this.requirementsCheckTarget.classList.add("opacity-0");
	}

	showRequirementsCheck() {
		if (!this.hasRequirementsListTarget || !this.hasRequirementsCheckTarget) return;
		
		this.passwordCheckShown = true;
		this.requirementsListTarget.classList.remove("opacity-100");
		this.requirementsListTarget.classList.add("opacity-0");
		this.requirementsCheckTarget.classList.remove("opacity-0");
		this.requirementsCheckTarget.classList.add("opacity-100", "checkmark-animate");
		
		setTimeout(() => {
			this.requirementsTarget.classList.add("shine-once");
			setTimeout(() => {
				this.requirementsTarget.classList.remove("shine-once");
			}, 1500);
		}, 500);
		
		setTimeout(() => {
			this.requirementsCheckTarget.classList.remove("checkmark-animate");
		}, 500);
	}

	toggleCurrentPasswordVisibility(event) {
		event.preventDefault();
		
		if (!this.hasCurrentPasswordTarget || !this.hasEyeCurrentIconTarget || !this.hasEyeSlashCurrentIconTarget) {
			return;
		}

		this.currentPasswordVisible = !this.currentPasswordVisible;
		this.currentPasswordTarget.type = this.currentPasswordVisible ? "text" : "password";
		this.eyeCurrentIconTarget.classList.toggle("hidden", this.currentPasswordVisible);
		this.eyeSlashCurrentIconTarget.classList.toggle("hidden", !this.currentPasswordVisible);
		
		if (this.hasToggleCurrentButtonTarget) {
			this.toggleCurrentButtonTarget.setAttribute(
				"aria-label",
				this.currentPasswordVisible ? "Hide password" : "Show password"
			);
		}
	}

	togglePasswordVisibility(event) {
		event.preventDefault();
		
		if (!this.hasPasswordTarget || !this.hasEyeIconTarget || !this.hasEyeSlashIconTarget) {
			return;
		}

		this.passwordVisible = !this.passwordVisible;
		this.passwordTarget.type = this.passwordVisible ? "text" : "password";
		this.eyeIconTarget.classList.toggle("hidden", this.passwordVisible);
		this.eyeSlashIconTarget.classList.toggle("hidden", !this.passwordVisible);
		
		if (this.hasToggleButtonTarget) {
			this.toggleButtonTarget.setAttribute(
				"aria-label",
				this.passwordVisible ? "Hide password" : "Show password"
			);
		}
	}

	toggleConfirmationVisibility(event) {
		event.preventDefault();
		
		if (!this.hasConfirmationTarget || !this.hasEyeConfirmationIconTarget || !this.hasEyeSlashConfirmationIconTarget) {
			return;
		}

		this.confirmationVisible = !this.confirmationVisible;
		this.confirmationTarget.type = this.confirmationVisible ? "text" : "password";
		this.eyeConfirmationIconTarget.classList.toggle("hidden", this.confirmationVisible);
		this.eyeSlashConfirmationIconTarget.classList.toggle("hidden", !this.confirmationVisible);
		
		if (this.hasToggleConfirmationButtonTarget) {
			this.toggleConfirmationButtonTarget.setAttribute(
				"aria-label",
				this.confirmationVisible ? "Hide password" : "Show password"
			);
		}
	}

	// ==================== Avatar Methods ====================

	switchToColorTab(event) {
		event.preventDefault();
		this.activeAvatarTab = "color";
		
		// Update tab styles
		if (this.hasColorTabTarget) {
			this.colorTabTarget.classList.add("bg-violet-600/70", "text-white");
			this.colorTabTarget.classList.remove("text-slate-400", "hover:text-slate-200");
		}
		if (this.hasImageTabTarget) {
			this.imageTabTarget.classList.remove("bg-violet-600/70", "text-white");
			this.imageTabTarget.classList.add("text-slate-400", "hover:text-slate-200");
		}
		
		// Show/hide panels
		if (this.hasColorPanelTarget) {
			this.colorPanelTarget.classList.remove("hidden");
		}
		if (this.hasImagePanelTarget) {
			this.imagePanelTarget.classList.add("hidden");
		}
		
		// Clear file input and mark avatar for removal
		if (this.hasFileInputTarget) {
			this.fileInputTarget.value = "";
		}
		if (this.hasSelectedFileInfoTarget) {
			this.selectedFileInfoTarget.classList.add("hidden");
		}
		if (this.hasFileTypeErrorTarget) {
			this.fileTypeErrorTarget.classList.add("hidden");
		}
		
		// Set remove_avatar flag to remove existing avatar
		if (this.hasRemoveAvatarFieldTarget) {
			this.removeAvatarFieldTarget.value = "1";
		}
		
		// Update preview to show color avatar
		this.showColorPreview();
	}

	switchToImageTab(event) {
		event.preventDefault();
		this.activeAvatarTab = "image";
		
		// Update tab styles
		if (this.hasImageTabTarget) {
			this.imageTabTarget.classList.add("bg-violet-600/70", "text-white");
			this.imageTabTarget.classList.remove("text-slate-400", "hover:text-slate-200");
		}
		if (this.hasColorTabTarget) {
			this.colorTabTarget.classList.remove("bg-violet-600/70", "text-white");
			this.colorTabTarget.classList.add("text-slate-400", "hover:text-slate-200");
		}
		
		// Show/hide panels
		if (this.hasImagePanelTarget) {
			this.imagePanelTarget.classList.remove("hidden");
		}
		if (this.hasColorPanelTarget) {
			this.colorPanelTarget.classList.add("hidden");
		}
		
		// Clear remove_avatar flag since we're using image mode
		if (this.hasRemoveAvatarFieldTarget) {
			this.removeAvatarFieldTarget.value = "0";
		}
		
		// Show image preview if exists
		this.showImagePreview();
	}

	updateColorPreview(event) {
		const color = event.target.value;
		const colorPreview = document.getElementById("avatar-color-preview");
		
		if (colorPreview) {
			colorPreview.style.backgroundColor = color;
		}
	}

	previewImage(event) {
		const file = event.target.files[0];
		
		if (!file) {
			this.clearSelectedFile();
			return;
		}
		
		// Client-side validation for file type
		const allowedTypes = ["image/jpeg", "image/png"];
		const allowedExtensions = [".jpg", ".jpeg", ".png"];
		const fileName = file.name.toLowerCase();
		const hasValidExtension = allowedExtensions.some(ext => fileName.endsWith(ext));
		
		if (!allowedTypes.includes(file.type) || !hasValidExtension) {
			// Show error
			if (this.hasFileTypeErrorTarget) {
				this.fileTypeErrorTarget.classList.remove("hidden");
			}
			if (this.hasSelectedFileInfoTarget) {
				this.selectedFileInfoTarget.classList.add("hidden");
			}
			// Clear the file input
			event.target.value = "";
			return;
		}
		
		// Hide error if previously shown
		if (this.hasFileTypeErrorTarget) {
			this.fileTypeErrorTarget.classList.add("hidden");
		}
		
		// Show preview
		const reader = new FileReader();
		reader.onload = (e) => {
			if (this.hasSelectedFilePreviewTarget) {
				this.selectedFilePreviewTarget.src = e.target.result;
			}
			if (this.hasSelectedFileNameTarget) {
				this.selectedFileNameTarget.textContent = file.name;
			}
			if (this.hasSelectedFileInfoTarget) {
				this.selectedFileInfoTarget.classList.remove("hidden");
			}
			
			// Update the main avatar preview
			const imagePreview = document.getElementById("avatar-image-preview");
			const colorPreview = document.getElementById("avatar-color-preview");
			
			if (imagePreview) {
				imagePreview.src = e.target.result;
				imagePreview.classList.remove("hidden");
			}
			if (colorPreview) {
				colorPreview.classList.add("hidden");
			}
		};
		reader.readAsDataURL(file);
	}

	clearSelectedFile() {
		if (this.hasFileInputTarget) {
			this.fileInputTarget.value = "";
		}
		if (this.hasSelectedFileInfoTarget) {
			this.selectedFileInfoTarget.classList.add("hidden");
		}
		if (this.hasFileTypeErrorTarget) {
			this.fileTypeErrorTarget.classList.add("hidden");
		}
		
		// Revert preview to existing avatar or color
		const imagePreview = document.getElementById("avatar-image-preview");
		const colorPreview = document.getElementById("avatar-color-preview");
		
		// Check if there's an existing avatar by checking if the image has a real src
		const hasExistingAvatar = imagePreview && imagePreview.dataset.existingAvatar === "true";
		
		if (hasExistingAvatar) {
			// Restore existing avatar
			if (imagePreview) {
				imagePreview.src = imagePreview.dataset.originalSrc;
				imagePreview.classList.remove("hidden");
			}
			if (colorPreview) {
				colorPreview.classList.add("hidden");
			}
		} else {
			// Show color preview
			if (imagePreview) {
				imagePreview.classList.add("hidden");
			}
			if (colorPreview) {
				colorPreview.classList.remove("hidden");
			}
		}
	}

	showColorPreview() {
		const imagePreview = document.getElementById("avatar-image-preview");
		const colorPreview = document.getElementById("avatar-color-preview");
		
		if (imagePreview) {
			imagePreview.classList.add("hidden");
		}
		if (colorPreview) {
			colorPreview.classList.remove("hidden");
		}
	}

	showImagePreview() {
		const imagePreview = document.getElementById("avatar-image-preview");
		const colorPreview = document.getElementById("avatar-color-preview");
		
		// Only show image preview if there's an actual image src
		if (imagePreview && imagePreview.src && !imagePreview.src.endsWith("/")) {
			imagePreview.classList.remove("hidden");
			if (colorPreview) {
				colorPreview.classList.add("hidden");
			}
		}
	}
}
