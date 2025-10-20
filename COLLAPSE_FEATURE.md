# Collapsible Study Groups Feature

## Overview

The course cards now have a **toggle collapse/expand** feature that allows users to hide study groups after viewing them, providing better navigation and reduced visual clutter.

---

## How It Works

### User Experience

1. **Initial State**

    - Course card shows "View Study Groups →" button in blue
    - Study groups section is collapsed (hidden)

2. **Click to Expand**

    - Button changes to "Hide Study Groups ↑" in gray
    - Study groups section smoothly expands with animation
    - Turbo Frame loads content from server
    - Course card gets "expanded" class

3. **Click to Collapse**
    - Button changes back to "View Study Groups →" in blue
    - Study groups section smoothly collapses with animation
    - Content is cleared from memory
    - Course card removes "expanded" class

---

## Technical Implementation

### 1. View Changes (`app/views/courses/index.html.erb`)

**Added Data Attributes:**

```erb
<div class="course-card"
     data-controller="courses"
     data-courses-expanded-value="false"
     data-courses-course-id-value="<%= course.course_id %>">
```

**Updated Button:**

```erb
<%= link_to course_path(course),
            class: "btn btn-primary toggle-btn",
            data: {
              action: "click->courses#toggle",
              courses_target: "toggleButton",
              turbo_frame: "course_#{course.course_id}_details"
            } do %>
  <span data-courses-target="buttonText">View Study Groups →</span>
<% end %>
```

**Added Target to Frame:**

```erb
<turbo-frame id="course_<%= course.course_id %>_details"
             class="course-details"
             data-courses-target="frameContent">
```

### 2. Stimulus Controller (`app/javascript/controllers/courses_controller.js`)

**Static Declarations:**

```javascript
static targets = ["toggleButton", "buttonText", "frameContent"]
static values = { expanded: Boolean, courseId: Number }
```

**Toggle Method:**

```javascript
toggle(event) {
  if (this.expandedValue) {
    // If already expanded, prevent navigation and collapse
    event.preventDefault()
    this.collapse()
  } else {
    // If collapsed, let Turbo Frame handle the request
    // The turbo:frame-load event will trigger expand()
  }
}
```

**Expand Method:**

```javascript
expand() {
  this.expandedValue = true
  this.element.classList.add("expanded")
  this.buttonTextTarget.textContent = "Hide Study Groups ↑"
  this.toggleButtonTarget.classList.remove("btn-primary")
  this.toggleButtonTarget.classList.add("btn-secondary")
}
```

**Collapse Method:**

```javascript
collapse() {
  this.expandedValue = false
  this.frameContentTarget.innerHTML = ""
  this.element.classList.remove("expanded")
  this.buttonTextTarget.textContent = "View Study Groups →"
  this.toggleButtonTarget.classList.remove("btn-secondary")
  this.toggleButtonTarget.classList.add("btn-primary")
}
```

**Event Listener:**

```javascript
connect() {
  // Listen for Turbo Frame load completion
  this.frameContentTarget.addEventListener("turbo:frame-load", () => {
    if (this.frameContentTarget.innerHTML.trim() &&
        !this.frameContentTarget.querySelector('.empty-state')) {
      this.expand()
    }
  })
}
```

### 3. CSS Styles (`app/assets/stylesheets/application.css`)

**Transition Properties:**

```css
.course-details {
    margin-top: 1.5rem;
    overflow: hidden;
    transition: max-height 0.4s ease-out, opacity 0.3s ease-out,
        margin-top 0.3s ease-out;
    max-height: 3000px;
    opacity: 1;
}
```

**Collapsed State:**

```css
.course-card:not(.expanded) .course-details {
    max-height: 0;
    opacity: 0;
    margin-top: 0;
}
```

**Button Transitions:**

```css
.toggle-btn {
    transition: all 0.2s ease;
}

.course-card.expanded .toggle-btn {
    transform: translateY(0);
}
```

---

## Key Features

### 1. **Smooth Animations**

-   400ms for height transition
-   300ms for opacity fade
-   Easing functions for natural feel

### 2. **State Management**

-   Stimulus value `expandedValue` tracks state
-   Boolean true/false for clarity
-   Prevents double-loading

### 3. **Visual Indicators**

-   Button text changes: "View" ↔ "Hide"
-   Button color changes: Blue ↔ Gray
-   Arrow direction: → (expand) ↑ (collapse)

### 4. **Memory Management**

-   Collapsed frames clear their content
-   Reduces DOM size for better performance
-   Fresh data loaded on each expand

### 5. **Event-Driven**

-   Listens to `turbo:frame-load` event
-   Automatically expands after content loads
-   No manual DOM polling needed

---

## Benefits

### For Users

✅ **Better Navigation** - Collapse cards you're done viewing  
✅ **Reduced Clutter** - Focus on relevant content  
✅ **Intuitive UX** - Standard expand/collapse pattern  
✅ **Visual Feedback** - Clear state indicators  
✅ **Smooth Experience** - No jarring page jumps

### For Developers

✅ **Clean Code** - Separation of concerns (View/Controller/Styles)  
✅ **Hotwire Integration** - Works seamlessly with Turbo Frames  
✅ **Maintainable** - Clear method names and logic flow  
✅ **Extensible** - Easy to add more features  
✅ **Performant** - CSS animations, minimal JS

---

## Testing the Feature

### Manual Testing Steps

1. **Start the server:**

    ```bash
    rails server
    ```

2. **Visit homepage:**

    ```
    http://localhost:3000
    ```

3. **Test expand:**

    - Click "View Study Groups →" on any course
    - Watch card expand smoothly
    - Observe button change to "Hide Study Groups ↑" (gray)

4. **Test collapse:**

    - Click "Hide Study Groups ↑"
    - Watch card collapse smoothly
    - Observe button change back to "View Study Groups →" (blue)

5. **Test multiple cards:**

    - Expand multiple courses
    - Collapse them in different orders
    - Verify each works independently

6. **Test content reload:**
    - Expand a course
    - Collapse it
    - Expand again
    - Verify fresh data is loaded

### Browser DevTools Testing

**Check Network Tab:**

-   First expand: Network request to load study groups
-   Collapse: No network request
-   Second expand: Fresh network request

**Check Console:**

-   Should see "Courses controller connected" for each card
-   No errors during collapse/expand

**Check Elements:**

-   Expanded card has `class="course-card expanded"`
-   Collapsed card has `class="course-card"`
-   Frame content clears on collapse

---

## Future Enhancements

Possible additions to consider:

1. **Remember State** - Use localStorage to remember which cards are expanded
2. **Collapse All Button** - Add button to collapse all expanded cards
3. **Keyboard Shortcuts** - Add keyboard support (Space/Enter to toggle)
4. **Animation Options** - Allow users to disable animations
5. **Auto-Collapse** - Collapse other cards when expanding a new one

---

## Troubleshooting

### Button doesn't change on click

-   Check browser console for JS errors
-   Verify Stimulus controller is connected
-   Check data attributes are present in HTML

### Animation is jumpy

-   Verify CSS transitions are applied
-   Check for conflicting CSS rules
-   Try adjusting `max-height` value if content is taller

### Content doesn't load

-   Check Turbo Frame is properly configured
-   Verify route returns correct response
-   Check browser network tab for errors

### Multiple clicks cause issues

-   Stimulus value prevents double-toggling
-   Event.preventDefault() stops navigation when expanded
-   Check event listener is only added once

---

## Code Files Modified

1. ✅ `app/views/courses/index.html.erb` - Added data attributes and targets
2. ✅ `app/javascript/controllers/courses_controller.js` - Added toggle logic
3. ✅ `app/assets/stylesheets/application.css` - Added animations
4. ✅ `QUICK_START.md` - Updated documentation

**Total Changes:** ~50 lines of code added/modified

---

## Summary

The collapsible feature provides a polished, professional user experience while maintaining the simplicity of the Hotwire approach. Users can now manage their view by collapsing courses they're done reviewing, reducing visual clutter and improving navigation efficiency.

**Key Takeaway:** This demonstrates how Stimulus values and targets make it easy to add stateful interactions while keeping the code clean and maintainable.
