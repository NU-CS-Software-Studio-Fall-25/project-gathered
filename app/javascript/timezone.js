// Utility to check if a date matches today in the user's local timezone
function isToday(dateString) {
  // Parse the ISO date string (YYYY-MM-DD) as local date, not UTC
  const [year, month, day] = dateString.split('-').map(num => parseInt(num, 10));

  // Get today's date in local timezone
  const today = new Date();
  const todayYear = today.getFullYear();
  const todayMonth = today.getMonth() + 1; // getMonth() is 0-indexed
  const todayDay = today.getDate();

  console.log('Checking date:', dateString, '-> Year:', year, 'Month:', month, 'Day:', day);
  console.log('Today is:', 'Year:', todayYear, 'Month:', todayMonth, 'Day:', todayDay);
  console.log('Match?', year === todayYear && month === todayMonth && day === todayDay);

  // Compare the date components
  return year === todayYear && month === todayMonth && day === todayDay;
}

// Highlight today's date on calendar
document.addEventListener('DOMContentLoaded', function() {
  console.log('DOM loaded, looking for calendar cells...');
  const calendarCells = document.querySelectorAll('.simple-calendar td');
  console.log('Found', calendarCells.length, 'calendar cells');

  calendarCells.forEach(cell => {
    const dateAttr = cell.getAttribute('data-date');
    console.log('Cell data-date:', dateAttr);
    if (dateAttr && isToday(dateAttr)) {
      console.log('Adding today class to cell with date:', dateAttr);
      cell.classList.add('today');
    }
  });
});

// Also handle Turbo navigation
document.addEventListener('turbo:load', function() {
  console.log('Turbo loaded, looking for calendar cells...');
  const calendarCells = document.querySelectorAll('.simple-calendar td');
  console.log('Found', calendarCells.length, 'calendar cells');

  calendarCells.forEach(cell => {
    const dateAttr = cell.getAttribute('data-date');
    console.log('Cell data-date:', dateAttr);
    // Remove any existing 'today' class first
    cell.classList.remove('today');
    // Add it back if it's today
    if (dateAttr && isToday(dateAttr)) {
      console.log('Adding today class to cell with date:', dateAttr);
      cell.classList.add('today');
    }
  });
});
