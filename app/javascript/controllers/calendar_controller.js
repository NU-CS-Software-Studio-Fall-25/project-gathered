import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log('Calendar controller connected');
    this.highlightToday();
    this.setupSidebar();
  }

  setupSidebar() {
    this.popup = document.getElementById('calendar-popup');
    this.popupContent = document.getElementById('popup-content');
    this.closeButton = document.getElementById('close-popup');
    
    if (this.closeButton) {
      this.closeButton.addEventListener('click', (e) => {
        e.preventDefault();
        this.closePopup();
      });
    }
    
    // Close popup when clicking outside
    document.addEventListener('click', (e) => {
      if (this.popup && !this.popup.contains(e.target) && !e.target.closest('[data-action*="calendar#showDetails"]')) {
        this.closePopup();
      }
    });
  }

  showDetails(event) {
    event.preventDefault();
    event.stopPropagation();
    const link = event.currentTarget;
    
    const topic = link.dataset.studyGroupTopic;
    const course = link.dataset.studyGroupCourse;
    const location = link.dataset.studyGroupLocation;
    const start = link.dataset.studyGroupStart;
    const end = link.dataset.studyGroupEnd;
    const description = link.dataset.studyGroupDescription;
    const creator = link.dataset.studyGroupCreator;
    const url = link.dataset.studyGroupUrl;

    const content = `
      <div class="space-y-3 pt-4">
        <div>
          <h3 class="text-lg font-bold text-white mb-1">${this.escapeHtml(topic)}</h3>
          <p class="text-violet-300 text-xs">${this.escapeHtml(course)}</p>
        </div>

        <div class="space-y-2 text-sm">
          <div>
            <h4 class="text-xs font-semibold text-violet-300 mb-0.5">📍 Location</h4>
            <p class="text-white/90 text-xs">${this.escapeHtml(location)}</p>
          </div>

          <div>
            <h4 class="text-xs font-semibold text-violet-300 mb-0.5">🕐 Time</h4>
            <p class="text-white/90 text-xs">${this.escapeHtml(start)}</p>
            <p class="text-white/70 text-xs">Ends at ${this.escapeHtml(end)}</p>
          </div>

          ${description ? `
            <div>
              <h4 class="text-xs font-semibold text-violet-300 mb-0.5">📝 Description</h4>
              <p class="text-white/90 text-xs">${this.escapeHtml(description)}</p>
            </div>
          ` : ''}

          <div>
            <h4 class="text-xs font-semibold text-violet-300 mb-0.5">👤 Created by</h4>
            <p class="text-white/90 text-xs">${this.escapeHtml(creator)}</p>
          </div>
        </div>

        <div class="pt-2 border-t border-white/10">
          <a href="${url}" class="inline-flex items-center justify-center w-full rounded-lg bg-violet-600/90 px-3 py-2 text-xs font-semibold text-white hover:bg-violet-500/90 transition">
            View Full Details →
          </a>
        </div>
      </div>
    `;

    this.popupContent.innerHTML = content;
    
    // Position the popup relative to the clicked event
    const eventCell = link.closest('td');
    const cellRect = eventCell.getBoundingClientRect();
    const calendarContainer = this.element.getBoundingClientRect();
    
    // Determine which day of the week (0 = Sunday, 6 = Saturday)
    const dayOfWeek = Array.from(eventCell.parentElement.children).indexOf(eventCell);
    
    // Position: left for Wed-Sat (3-6), right for Sun-Tue (0-2)
    const positionLeft = dayOfWeek >= 3;
    
    // Calculate position relative to the calendar container
    const topOffset = cellRect.top - calendarContainer.top;
    
    this.popup.style.top = `${topOffset}px`;
    
    if (positionLeft) {
      // Position to the left of the event
      this.popup.style.left = 'auto';
      this.popup.style.right = `${calendarContainer.right - cellRect.left + 10}px`;
    } else {
      // Position to the right of the event
      this.popup.style.left = `${cellRect.right - calendarContainer.left + 10}px`;
      this.popup.style.right = 'auto';
    }
    
    this.popup.classList.remove('hidden');
  }

  closePopup() {
    if (this.popup) {
      this.popup.classList.add('hidden');
    }
  }

  escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }

  highlightToday() {
    const calendarCells = this.element.querySelectorAll('td[data-date]');
    console.log('Found', calendarCells.length, 'calendar cells with data-date');

    // Get today's date in local timezone
    const today = new Date();
    const todayYear = today.getFullYear();
    const todayMonth = today.getMonth() + 1; // getMonth() is 0-indexed
    const todayDay = today.getDate();
    
    console.log('Today is:', todayYear, '-', todayMonth, '-', todayDay);

    calendarCells.forEach(cell => {
      const dateAttr = cell.getAttribute('data-date');
      console.log('Checking cell with data-date:', dateAttr);

      if (dateAttr && this.isToday(dateAttr, todayYear, todayMonth, todayDay)) {
        console.log('Adding today highlight to:', dateAttr);
        cell.setAttribute('data-today', 'true');
      }
    });
  }

  isToday(dateString, todayYear, todayMonth, todayDay) {
    // Parse the ISO date string (YYYY-MM-DD)
    const [year, month, day] = dateString.split('-').map(num => parseInt(num, 10));
    
    const match = year === todayYear && month === todayMonth && day === todayDay;
    console.log(`Comparing ${dateString} (${year}-${month}-${day}) with today (${todayYear}-${todayMonth}-${todayDay}): ${match}`);
    
    return match;
  }
}
