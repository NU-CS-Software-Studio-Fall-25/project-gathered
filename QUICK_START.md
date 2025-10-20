# Quick Start Guide - Hotwire Demo

## Getting Started

### 1. Setup Database

```bash
# Create and migrate database
rails db:create
rails db:migrate

# Load sample data (150 students, 7 courses, multiple study groups)
rails db:seed
```

### 2. Start the Server

```bash
rails server
```

Visit: http://localhost:3000

---

## What You'll See

### Homepage (`/`)

-   7 course cards with:
    -   Course name (e.g., "COMP_SCI 340 - Networking")
    -   Professor name
    -   Description
    -   Study group count
    -   Enrolled student count
-   Click "View Study Groups →" on any course

### Course Detail (Inline via Turbo Frame)

When you click "View Study Groups":

-   **Course card expands** (no page reload!)
-   **Button changes** to "Hide Study Groups ↑" with different color
-   Shows list of study groups for that course
-   Each study group displays:
    -   Topic (e.g., "DNS Proxy project")
    -   Date and time
    -   Location
    -   Creator name
    -   Member count
    -   Status badge (Upcoming/Ongoing/Past)
    -   Join/Leave button
-   **"Create New Group" button** at the top

When you click "Hide Study Groups":

-   **Course card collapses smoothly** with animation
-   **Button changes** back to "View Study Groups →"
-   Content is cleared from memory
-   Can expand again to reload fresh data

### Creating a Study Group

1. Click "Create New Group"
2. **Form appears inline** (no page reload!)
3. Fill out:
    - Topic (required)
    - Description
    - Location
    - Start time (required)
    - End time (required)
4. Click "Create Study Group"
5. **New group appears at top of list** (via Turbo Stream)
6. **Success message shows** in top-right corner
7. **Form disappears automatically**

### Joining a Study Group

1. Click "Join Group" button
2. **Button changes to "Leave Group"** (no page reload!)
3. **Member count updates** (e.g., "5 members" → "6 members")
4. **Success message appears**: "You joined the study group!"
5. **✓ Joined badge** appears next to Leave button

### Leaving a Study Group

1. Click "Leave Group" button
2. **Button changes back to "Join Group"**
3. **Member count decreases**
4. **Info message appears**: "You left the study group."

---

## Key Features to Notice

### 1. **No Page Reloads**

-   Everything happens in-place
-   Scroll position maintained
-   Fast, smooth transitions

### 2. **Progressive Enhancement**

-   Try disabling JavaScript → still works (falls back to full page loads)
-   View source → actual HTML, not `<div id="root"></div>`

### 3. **Visual Feedback**

-   Status badges: Upcoming (blue), Ongoing (green), Past (gray)
-   Hover effects on cards
-   Smooth collapse/expand animations
-   Button color changes (blue → gray when expanded)
-   Flash messages auto-dismiss after 5 seconds

### 4. **Responsive Design**

-   Resize browser → layout adapts
-   Works on mobile screens
-   Touch-friendly buttons

---

## Testing Different Scenarios

### Scenario 1: Multiple Users Viewing Same Course

Open two browser windows:

1. Both visit the same course
2. In window 1, join a study group
3. In window 2, refresh to see updated member count
4. _(Note: Real-time broadcasting would show instant updates without refresh)_

### Scenario 2: Creating Multiple Groups

1. View a course's study groups
2. Create a new group
3. Notice it appears at the top of the list
4. Create another → both visible
5. All animations smooth

### Scenario 3: Validation Errors

1. Click "Create New Group"
2. Leave topic blank
3. Click "Create Study Group"
4. **Form shows error message** (stays in Turbo Frame)
5. Fix error and resubmit
6. **Success!**

### Scenario 4: Past Groups

1. Look for groups marked "PAST"
2. Notice they're slightly grayed out
3. "Join Group" button is disabled
4. Status badge is gray

---

## Browser Developer Tools

### Check Network Tab

1. Open DevTools → Network tab
2. Click "View Study Groups" on a course
3. Notice:

    - Request includes `Turbo-Frame` header
    - Response is partial HTML (not full page)
    - Only ~2KB transferred

4. Click "Join Group"
5. Notice:
    - Response Content-Type: `text/vnd.turbo-stream.html`
    - Response contains `<turbo-stream>` tags
    - DOM updates automatically

### Check Console

You should see:

```
Courses controller connected
Study groups controller connected
```

No errors!

---

## Sample Data Overview

After `rails db:seed`, you'll have:

### Students: 150

-   Randomly generated names (via Faker gem)
-   Distributed across courses

### Courses: 7

1. COMP_SCI 110 – Intro to CS
2. COMP_SCI 211 – Fund. II
3. COMP_SCI 214 – Data Structures
4. COMP_SCI 340 – Networking
5. IEMS 341 – Social Networks
6. MATH 240 – Linear Algebra
7. STAT 350 – Regression

### Study Groups: 2-5 per course

-   Mix of upcoming, ongoing, and past sessions
-   Realistic topics based on course
-   8-20 members each
-   Various locations and times

---

## Routes Reference

```ruby
# View all courses
GET  /                                    # root_path

# View specific course (Turbo Frame or full page)
GET  /courses/:id                         # course_path(@course)

# Create study group form
GET  /courses/:course_id/study_groups/new # new_course_study_group_path(@course)

# Create study group
POST /courses/:course_id/study_groups     # course_study_groups_path(@course)

# View study group details
GET  /study_groups/:id                    # study_group_path(@study_group)

# Join a study group
POST /study_groups/:id/join               # join_study_group_path(@study_group)

# Leave a study group
DELETE /study_groups/:id/leave            # leave_study_group_path(@study_group)
```

---

## Simulating Current User

Currently, the app uses:

```ruby
Student.first&.student_id
```

This simulates being logged in as the first student.

### To Test as Different Users

In Rails console:

```ruby
# Find different student IDs
Student.pluck(:student_id, :name).first(5)

# Temporarily change in controller
# Replace Student.first with Student.find(specific_id)
```

---

## Common Questions

### Q: Why does clicking "View Study Groups" expand the card instead of navigating?

**A:** The link has `data: { turbo_frame: "course_X_details" }`, which tells Turbo to load the response into that specific frame.

### Q: How does the "Join Group" button update without JavaScript?

**A:** The button has `data: { turbo_stream: true }`. The server responds with Turbo Stream instructions that Hotwire's JavaScript (built-in) executes automatically.

### Q: What if I want to navigate to a full course page?

**A:** Visit `/courses/:id` directly in the URL bar, or remove the `turbo_frame` data attribute from the link.

### Q: Can I see the Turbo Stream response?

**A:** Yes! In DevTools Network tab, click a "Join Group" request, then view the Response tab. You'll see XML-like `<turbo-stream>` tags.

---

## Next: Read HOTWIRE_DEMO.md

For a complete technical deep-dive, see `HOTWIRE_DEMO.md` which covers:

-   Detailed architecture
-   How Turbo Frames work
-   How Turbo Streams work
-   Stimulus controller patterns
-   Comparison with JSON API approach
-   Extension ideas

---

## Enjoy the Demo! 🎉

This implementation shows how modern Rails with Hotwire can build highly interactive applications without the complexity of separate API backends and heavy JavaScript frameworks.
