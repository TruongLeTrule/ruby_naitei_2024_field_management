document.addEventListener('turbo:load', () => {
  const dateInput = document.getElementById('date-input')
  const findScheduleLink = document.getElementById('find-schedule-link')
  const baseUrl = findScheduleLink?.getAttribute('href')

  const today = new Date()
  findScheduleLink &&
    findScheduleLink.setAttribute(
      'href',
      `${baseUrl}?date=${today.getFullYear()}-${
        today.getMonth() + 1
      }-${today.getDate()}`
    )

  dateInput &&
    dateInput.addEventListener('change', () => {
      findScheduleLink.setAttribute(
        'href',
        `${baseUrl}?date=${dateInput.value}`
      )
    })
})
