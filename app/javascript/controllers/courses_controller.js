import { Controller } from "@hotwired/stimulus";

// Handles course card interactions and expanding/collapsing details
export default class extends Controller {
    static values = { 
        expanded: Boolean, 
        courseId: Number,
        selected: { type: Boolean, default: false }
    };

    connect() {
        console.log("Courses controller connected");

        // Ensure the text visibility is correct on initial connect
        // This handles the case where a new course is added and the DOM is refreshed
        const clickToView = this.element.querySelector('.click-to-view-text');
        const showingGroups = this.element.querySelector('.showing-groups-text');
        
        // Handle initial state on page load
        const selectedCourseId = sessionStorage.getItem('selectedCourseId');
        
        // Check if this course ID still exists in the DOM
        const enrolledCourses = document.getElementById('enrolled-courses');
        if (!enrolledCourses) return;
        
        const courseItems = enrolledCourses.querySelectorAll('.course-item');
        const selectedCourseExists = Array.from(courseItems).some(
            item => item.getAttribute('data-course-id') === selectedCourseId
        );
        
        // If selected course doesn't exist anymore, clear sessionStorage
        if (selectedCourseId && !selectedCourseExists) {
            sessionStorage.removeItem('selectedCourseId');
            sessionStorage.removeItem('courseOrder');
            // Make sure all courses are visible and text is reset
            this.element.style.display = '';
            this.element.style.opacity = '1';
            this.element.style.transform = 'translateX(0)';
            if (clickToView) clickToView.style.display = '';
            if (showingGroups) showingGroups.style.display = 'none';
            this.toggleCourseListCompact(false);
            return;
        }
        
        if (selectedCourseId === this.courseIdValue?.toString()) {
            // This is the selected course
            this.element.setAttribute('data-selected', 'true');
            
            // Toggle the text visibility for selected state
            if (clickToView) clickToView.style.display = 'none';
            if (showingGroups) showingGroups.style.display = '';
            this.toggleCourseListCompact(true);
            
            this.loadStudyGroups();
            
            // Scroll to top immediately on page load (no smooth animation)
            window.scrollTo(0, 0);

            // Hide all other courses immediately (no animation needed on initial load)
            courseItems.forEach(item => {
                if (item !== this.element) {
                    item.style.display = 'none';
                }
            });
        } else if (selectedCourseId) {
            // Another course is selected, hide this one immediately
            this.element.style.display = 'none';
            // Ensure text is in default state
            if (clickToView) clickToView.style.display = '';
            if (showingGroups) showingGroups.style.display = 'none';
        } else {
            // No course is selected, make sure this one is visible and text is reset
            this.element.style.display = '';
            this.element.style.opacity = '1';
            this.element.style.transform = 'translateX(0)';
            if (clickToView) clickToView.style.display = '';
            if (showingGroups) showingGroups.style.display = 'none';
            this.toggleCourseListCompact(false);
        }
    }

    selectCourse(event) {
        // Don't handle clicks on buttons inside the course item (like unenroll)
        if (event.target.closest('button[type="submit"]')) {
            return;
        }

        // Toggle selection state of this course
        const wasSelected = this.element.getAttribute('data-selected') === 'true';
        const enrolledCourses = document.getElementById('enrolled-courses');
        const courseItems = Array.from(enrolledCourses.querySelectorAll('.course-item'));
        
        if (!wasSelected) {
            // Store the current order of courses for later
            const courseOrder = courseItems.map(item => item.getAttribute('data-course-id'));
            sessionStorage.setItem('courseOrder', JSON.stringify(courseOrder));
            
            // Hide all other courses with a fade out animation
            courseItems.forEach(item => {
                if (item !== this.element) {
                    item.style.transition = 'opacity 220ms cubic-bezier(0.4, 0, 0.2, 1), transform 220ms cubic-bezier(0.4, 0, 0.2, 1)';
                    item.style.opacity = '0';
                    item.style.transform = 'translateY(0.5rem) scale(0.98)';
                    setTimeout(() => {
                        item.style.display = 'none';
                        item.style.transition = '';
                    }, 220);
                }
            });

            // Add selected state to this course
            this.element.setAttribute('data-selected', 'true');
            
            // Toggle the text visibility
            const clickToView = this.element.querySelector('.click-to-view-text');
            const showingGroups = this.element.querySelector('.showing-groups-text');
            if (clickToView) clickToView.style.display = 'none';
            if (showingGroups) showingGroups.style.display = '';
            this.toggleCourseListCompact(true);
            
            // Save selected course ID
            sessionStorage.setItem('selectedCourseId', this.courseIdValue);
            this.loadStudyGroups();
            
            // Scroll to top of the page smoothly
            window.scrollTo({ top: 0, behavior: 'smooth' });
        } else {
            // Remove selected state
            this.element.setAttribute('data-selected', 'false');
            sessionStorage.removeItem('selectedCourseId');
            this.toggleCourseListCompact(false);
            
            // Toggle the text visibility back
            const clickToView = this.element.querySelector('.click-to-view-text');
            const showingGroups = this.element.querySelector('.showing-groups-text');
            if (clickToView) clickToView.style.display = '';
            if (showingGroups) showingGroups.style.display = 'none';
            
            // Get the stored course order
            const courseOrder = JSON.parse(sessionStorage.getItem('courseOrder') || '[]');
            
            // Show all courses with a fade in animation
            courseItems.forEach(item => {
                item.style.display = ''; // Reset display first
                requestAnimationFrame(() => {
                    item.style.transition = 'opacity 260ms cubic-bezier(0.4, 0, 0.2, 1), transform 260ms cubic-bezier(0.4, 0, 0.2, 1)';
                    item.style.opacity = '1';
                    item.style.transform = 'translateY(0) scale(1)';
                    item.addEventListener('transitionend', () => {
                        item.style.transition = '';
                    }, { once: true });
                });
            });

            // Restore the original order
            if (courseOrder.length > 0) {
                const fragment = document.createDocumentFragment();
                courseOrder.forEach(courseId => {
                    const item = courseItems.find(item => item.getAttribute('data-course-id') === courseId);
                    if (item) fragment.appendChild(item);
                });
                enrolledCourses.appendChild(fragment);
            }

            // Clear study groups panel
            const container = document.getElementById('study-groups-container');
            if (container) {
                const emptyState = container.getAttribute('data-empty-state');
                container.innerHTML = emptyState || `
                    <div class="text-center rounded-lg border border-white/10 bg-white/5 p-8">
                        <div class="text-4xl mb-2">👥</div>
                        <h3 class="text-lg font-semibold text-white mb-1">Study Groups</h3>
                        <p class="text-sm text-slate-300">Click on a course to view its study groups</p>
                    </div>
                `;
            }
        }

        // Prevent default link behavior
        event.preventDefault();
    }

    toggleCourseListCompact(compact) {
        const enrolledCourses = document.getElementById('enrolled-courses');
        if (!enrolledCourses) return;

        if (compact) {
            enrolledCourses.dataset.compact = 'true';
        } else {
            delete enrolledCourses.dataset.compact;
        }
    }

    loadStudyGroups() {
        const container = document.getElementById('study-groups-container');
        if (!container) return;

        // Store current height for smooth transition
        const currentHeight = container.offsetHeight;
        const previousOverflow = container.style.overflow || '';
        const transitionClasses = ['transition-all', 'duration-300', 'ease-out'];
        transitionClasses.forEach(cls => container.classList.add(cls));
        let cleanedUp = false;
        const cleanup = () => {
            if (cleanedUp) return;
            cleanedUp = true;
            container.style.height = '';
            container.style.overflow = previousOverflow;
            transitionClasses.forEach(cls => container.classList.remove(cls));
        };
        container.style.height = `${currentHeight}px`;
        container.style.overflow = 'hidden';
        
        // Fade out current content
        container.style.opacity = '0';
        
        // Wait for fade out
        setTimeout(() => {
            // Show loading state
            container.innerHTML = `
                <div class="text-center py-4">
                    <div class="animate-spin h-6 w-6 border-2 border-violet-500 rounded-full border-t-transparent mx-auto"></div>
                </div>
            `;
            
            // Allow container to animate to loading spinner height
            container.style.height = 'auto';
            const loadingHeight = container.offsetHeight;
            container.style.height = `${currentHeight}px`;
            
            // Trigger reflow
            container.offsetHeight;
            
            // Animate to new height and fade in
            container.style.height = `${loadingHeight}px`;
            container.style.opacity = '1';
        }, 150);
        
        // Load study groups
        fetch(`/courses/${this.courseIdValue}?partial=true`)
            .then(response => response.text())
            .then(html => {
                // Fade out loading spinner
                container.style.opacity = '0';
                
                setTimeout(() => {
                    const contentOnly = html.replace(/.*<body[^>]*>|<\/body>.*/g, '');
                    container.innerHTML = contentOnly;
                    
                    // Get the new content height
                    const newHeight = container.scrollHeight;
                    container.style.height = `${container.offsetHeight}px`;
                    
                    // Trigger reflow
                    container.offsetHeight;
                    
                    // Animate to new height and fade in
                    container.style.height = `${newHeight}px`;
                    container.style.opacity = '1';
                    
                    // Remove fixed height after animation
                    setTimeout(() => {
                        cleanup();
                    }, 300);
                }, 150);
            })
            .catch(error => {
                console.error('Error loading study groups:', error);
                container.style.opacity = '0';
                
                setTimeout(() => {
                    container.innerHTML = `
                        <div class="text-center py-8">
                            <div class="text-4xl mb-2">❌</div>
                            <h3 class="text-lg font-semibold text-white mb-1">Error Loading Study Groups</h3>
                            <p class="text-sm text-slate-300">Please try again</p>
                        </div>
                    `;
                    
                    // Get error state height
                    const errorHeight = container.scrollHeight;
                    container.style.height = `${container.offsetHeight}px`;
                    
                    // Trigger reflow
                    container.offsetHeight;
                    
                    // Animate to new height and fade in
                    container.style.height = `${errorHeight}px`;
                    container.style.opacity = '1';
                    
                    // Remove fixed height after animation
                    setTimeout(() => {
                        cleanup();
                    }, 300);
                }, 150);
            });
    }
}
