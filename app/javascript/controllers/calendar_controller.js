import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log('Calendar controller connected');
    this.highlightToday();
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
        console.log('Adding today class to:', dateAttr);
        cell.classList.add('today');
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
