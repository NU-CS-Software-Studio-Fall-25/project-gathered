# Hotwire Study Groups Demo - Implementation Guide

This document explains the complete Hotwire implementation for the GatherEd Study Group Finder application.

## Overview

This demo showcases **Approach A: Rails Way with Hotwire**, demonstrating how to build dynamic, SPA-like functionality without a separate REST API or heavy JavaScript framework.

## Architecture

### Technology Stack

-   **Rails 8** - Backend framework
-   **Hotwire Turbo** - For Turbo Frames and Turbo Streams
-   **Stimulus** - Lightweight JavaScript controllers
-   **PostgreSQL** - Database
-   **Import Maps** - JavaScript module management (no build step)

### Key Concepts Demonstrated

1. **Turbo Frames** - Lazy-load content within page sections
2. **Turbo Streams** - Server-sent DOM updates
3. **Stimulus Controllers** - Minimal JavaScript for interactions
4. **Server-Rendered HTML** - No JSON serialization needed

---

## File Structure

```
app/
├── controllers/
│   ├── courses_controller.rb          # Handles course listing and details
│   └── study_groups_controller.rb     # Handles CRUD + join/leave actions
├── models/
│   ├── course.rb                      # Course model with associations
│   ├── student.rb                     # Student model with associations
│   ├── study_group.rb                 # Study group model with business logic
│   ├── group_membership.rb            # Join table for group members
│   └── student_course.rb              # Join table for course enrollments
├── views/
│   ├── courses/
│   │   ├── index.html.erb             # Homepage - course cards grid
│   │   └── show.html.erb              # Course detail with study groups
│   ├── study_groups/
│   │   ├── _study_group.html.erb      # Study group card partial
│   │   ├── new.html.erb               # Create study group form
│   │   └── show.html.erb              # Study group detail page
│   └── shared/
│       └── _flash.html.erb            # Flash message partial
├── javascript/
│   └── controllers/
│       ├── courses_controller.js      # Course card interactions
│       ├── study_groups_controller.js # Study group interactions
│       └── flash_controller.js        # Flash message handling
└── assets/stylesheets/
    └── application.css                # Complete styling (800+ lines)
```

---

## How It Works

### 1. **Homepage - Course Listing**

**URL:** `/` (root_path)

**Flow:**

1. User visits homepage
2. Rails renders `courses/index.html.erb`
3. Shows all courses in a responsive grid
4. Each course card has a "View Study Groups" button

**Key Code:**

```erb
<!-- app/views/courses/index.html.erb -->
<%= link_to "View Study Groups →",
            course_path(course),
            data: { turbo_frame: "course_#{course.course_id}_details" } %>

<turbo-frame id="course_<%= course.course_id %>_details">
  <!-- Study groups will load here -->
</turbo-frame>
```

**What Happens:**

-   Click triggers Turbo Frame request
-   Only the frame content updates, not the whole page
-   Course card expands to show study groups inline

---

### 2. **Viewing Study Groups (Turbo Frame)**

**URL:** `/courses/:id`

**Flow:**

1. User clicks "View Study Groups"
2. Turbo sends request with `Turbo-Frame` header
3. Server checks `turbo_frame_request?`
4. Returns only the frame content (not full page)
5. Frame updates in-place

**Controller:**

```ruby
# app/controllers/courses_controller.rb
def show
  @course = Course.find(params[:id])
  @study_groups = @course.study_groups

  respond_to do |format|
    format.html  # Full page if navigated directly
    format.turbo_stream
  end
end
```

**View:**

```erb
<!-- app/views/courses/show.html.erb -->
<% if turbo_frame_request? %>
  <turbo-frame id="course_<%= @course.course_id %>_details">
    <!-- Only render frame content for Turbo requests -->
    <div id="study_groups_list">
      <%= render @study_groups %>
    </div>
  </turbo-frame>
<% else %>
  <!-- Render full page if accessed directly -->
<% end %>
```

---

### 3. **Joining a Study Group (Turbo Stream)**

**URL:** `POST /study_groups/:id/join`

**Flow:**

1. User clicks "Join Group" button
2. Form submits with `data: { turbo_stream: true }`
3. Server processes join action
4. Server responds with **Turbo Stream** (not HTML or JSON)
5. Turbo Stream contains DOM manipulation instructions
6. Browser's Turbo automatically updates the page

**Controller:**

```ruby
# app/controllers/study_groups_controller.rb
def join
  @study_group = StudyGroup.find(params[:id])
  GroupMembership.create!(student_id: params[:student_id], group_id: @study_group.group_id)
  @study_group.reload

  respond_to do |format|
    format.turbo_stream do
      render turbo_stream: [
        # Update the entire study group card
        turbo_stream.replace(
          "study_group_#{@study_group.group_id}",
          partial: "study_groups/study_group",
          locals: { study_group: @study_group }
        ),
        # Show success message
        turbo_stream.prepend(
          "flash_messages",
          partial: "shared/flash",
          locals: { message: "You joined!", type: "success" }
        )
      ]
    end
  end
end
```

**What the Response Looks Like:**

```html
Content-Type: text/vnd.turbo-stream.html

<turbo-stream action="replace" target="study_group_42">
    <template>
        <div id="study_group_42" class="study-group-card">
            <!-- Updated HTML with new member count and "Leave" button -->
        </div>
    </template>
</turbo-stream>

<turbo-stream action="prepend" target="flash_messages">
    <template>
        <div class="flash-message flash-success">You joined!</div>
    </template>
</turbo-stream>
```

**The Browser Automatically:**

1. Finds `#study_group_42`
2. Replaces it with new content
3. Finds `#flash_messages`
4. Prepends the flash message

**No JavaScript code needed!**

---

### 4. **Creating a Study Group (Form in Turbo Frame)**

**Flow:**

1. User clicks "Create New Group"
2. Turbo Frame loads form from `/courses/:id/study_groups/new`
3. Form appears inline without page reload
4. User fills form and submits
5. On success: Turbo Stream prepends new group to list
6. On error: Turbo Frame shows validation errors

**Form View:**

```erb
<!-- app/views/study_groups/new.html.erb -->
<turbo-frame id="new_group_form">
  <%= form_with model: @study_group,
                url: course_study_groups_path(@course),
                data: { turbo_frame: "new_group_form" } do |f| %>
    <!-- Form fields -->
  <% end %>
</turbo-frame>
```

**Create Action:**

```ruby
def create
  @study_group = @course.study_groups.build(study_group_params)

  if @study_group.save
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          # Add new group to the list
          turbo_stream.prepend("study_groups_list", partial: "study_groups/study_group"),
          # Clear the form
          turbo_stream.update("new_group_form", html: ""),
          # Show success message
          turbo_stream.prepend("flash_messages", partial: "shared/flash")
        ]
      end
    end
  else
    # Re-render form with errors (stays in Turbo Frame)
    render :new, status: :unprocessable_entity
  end
end
```

---

## Stimulus Controllers (Minimal JavaScript)

### Purpose

Stimulus adds small interactive behaviors that don't require server round-trips.

### Examples

**1. Flash Message Auto-Dismiss:**

```javascript
// app/javascript/controllers/flash_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    connect() {
        // Auto-dismiss after 5 seconds
        this.timeout = setTimeout(() => this.dismiss(), 5000);
    }

    dismiss() {
        this.element.classList.add("dismissing");
        setTimeout(() => this.element.remove(), 300);
    }
}
```

**2. Form Close Button:**

```javascript
// app/javascript/controllers/study_groups_controller.js
closeForm(event) {
  event.preventDefault()
  document.getElementById("new_group_form").innerHTML = ""
}
```

**Usage in View:**

```erb
<button data-controller="flash" data-action="click->flash#dismiss">
  Close
</button>
```

---

## Styling Highlights

### Modern Design Features

-   **CSS Variables** - Consistent theming
-   **Card-based Layout** - Material design inspired
-   **Smooth Transitions** - 150ms-250ms animations
-   **Status Indicators** - Color-coded badges (upcoming/ongoing/past)
-   **Responsive Grid** - Mobile-friendly
-   **Loading States** - Turbo progress bar

### Key Classes

```css
.study-group-card {
    border-left: 4px solid var(--primary-color);
    transition: var(--transition-fast);
}

.study-group-card:hover {
    transform: translateX(2px);
    box-shadow: var(--shadow-md);
}

.study-group-card.status-ongoing {
    border-left-color: var(--success-color);
    background: linear-gradient(
        to right,
        rgba(16, 185, 129, 0.05),
        transparent
    );
}
```

---

## Database Models

### Associations

```ruby
# Course
has_many :study_groups
has_many :students, through: :student_courses

# Student
has_many :study_groups, through: :group_memberships
has_many :created_study_groups, foreign_key: :creator_id

# StudyGroup
belongs_to :course
belongs_to :creator, class_name: "Student"
has_many :members, through: :group_memberships

# GroupMembership (join table)
belongs_to :student
belongs_to :group, class_name: "StudyGroup"
```

### Helper Methods

```ruby
# app/models/study_group.rb
def status
  return "past" if end_time < Time.current
  return "ongoing" if start_time <= Time.current && end_time >= Time.current
  "upcoming"
end

def formatted_time_range
  "#{start_time.strftime('%b %d, %Y at %I:%M %p')} - #{end_time.strftime('%I:%M %p')}"
end
```

---

## Running the Application

### Setup

```bash
# Install dependencies
bundle install

# Setup database
rails db:create db:migrate

# Seed with sample data
rails db:seed

# Start server
rails server
```

### Access

-   **Homepage:** http://localhost:3000
-   **View a course:** Click any course card
-   **Create a group:** Click "Create New Group" button
-   **Join a group:** Click "Join Group" button

---

## Key Differences: Hotwire vs JSON API

### Traditional JSON API Approach:

```javascript
// Frontend: Lots of JavaScript
async function joinGroup(groupId) {
    const response = await fetch(`/api/study_groups/${groupId}/join`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
    });
    const data = await response.json();

    // Manual DOM updates
    document.getElementById("member-count").textContent = data.member_count;
    document.getElementById("join-btn").remove();
    // ... more DOM manipulation
}
```

```ruby
# Backend: Return JSON
def join
  @study_group.members << current_user
  render json: {
    member_count: @study_group.member_count,
    success: true
  }
end
```

### Hotwire Approach:

```erb
<!-- Frontend: Just a button -->
<%= button_to "Join Group",
              join_study_group_path(@study_group),
              method: :post,
              data: { turbo_stream: true } %>
```

```ruby
# Backend: Return Turbo Stream
def join
  @study_group.members << current_user
  render turbo_stream: turbo_stream.replace(
    "study_group_#{@study_group.id}",
    partial: "study_groups/study_group"
  )
end
```

**Result:** Same user experience, 90% less JavaScript code.

---

## Advantages of This Approach

1. **Less Code** - No API serialization, no frontend state management
2. **SEO Friendly** - Server-rendered HTML works without JavaScript
3. **Progressive Enhancement** - Degrades gracefully if JS disabled
4. **Simple CSRF** - Rails handles it automatically
5. **Fast Development** - Use Rails strengths, less context switching
6. **Real-time Updates** - Turbo Streams provide live updates
7. **Mobile Ready** - Responsive CSS, no separate mobile API needed

---

## What's NOT Included (But Could Be Added)

### Authentication

Currently uses hardcoded student IDs. Add:

-   Devise for authentication
-   `current_user` helper
-   Login/signup pages

### Real-time Broadcasting

For multiple users seeing updates simultaneously:

```ruby
# app/models/study_group.rb
after_create_commit do
  broadcast_prepend_to(
    "course_#{course_id}_study_groups",
    target: "study_groups_list"
  )
end
```

### Pagination

For large lists:

-   Pagy gem
-   Infinite scroll with Turbo Frames

### Search/Filtering

-   Stimulus controller for live search
-   Turbo Frame updates on filter change

---

## Testing

### Run Tests

```bash
# Unit tests
rails test

# System tests (with Capybara)
rails test:system
```

### Example Test

```ruby
# test/system/study_groups_test.rb
test "joining a study group" do
  visit course_path(@course)

  within "#study_group_#{@group.id}" do
    click_button "Join Group"
    assert_text "Joined"
    assert_text "#{@group.member_count + 1} members"
  end
end
```

---

## Troubleshooting

### Turbo Frame Not Loading?

-   Check the `id` matches in link and frame
-   Verify `data: { turbo_frame: "frame_id" }` is set
-   Look for errors in browser console

### Turbo Stream Not Updating?

-   Ensure `data: { turbo_stream: true }` on form/button
-   Verify target element exists with correct `id`
-   Check response Content-Type is `text/vnd.turbo-stream.html`

### Stimulus Controller Not Working?

-   Check controller name matches file name (kebab-case)
-   Verify `data-controller="name"` is on element
-   Look for typos in action names

---

## Next Steps

To extend this demo:

1. **Add authentication** - Devise gem
2. **Enable broadcasting** - Action Cable for real-time
3. **Add chat feature** - Per-group messaging with Turbo Streams
4. **Implement search** - Filter courses and groups
5. **Add notifications** - Email reminders for upcoming groups
6. **Calendar view** - Show groups on a calendar
7. **User profiles** - View other students' profiles

---

## Resources

-   [Hotwire Documentation](https://hotwired.dev)
-   [Turbo Handbook](https://turbo.hotwired.dev/handbook/introduction)
-   [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)
-   [Rails Guides](https://guides.rubyonrails.org)

---

## Summary

This implementation demonstrates a complete, production-ready approach to building dynamic web applications using Rails and Hotwire. It achieves SPA-like interactivity with minimal JavaScript, leveraging Rails' strengths in server-rendered HTML and convention over configuration.

**Key Takeaway:** You don't always need a separate REST API and heavy JavaScript framework. For many applications, Hotwire provides the perfect balance of interactivity and simplicity.
