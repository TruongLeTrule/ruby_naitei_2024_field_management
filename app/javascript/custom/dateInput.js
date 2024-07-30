document.addEventListener('turbo:load', () => {
  const dateInput = document.getElementById('date-input')
  const findScheduleLink = document.getElementById('find-schedule-link')
  const baseUrl = findScheduleLink.href

  const today = new Date()
  findScheduleLink.href = `${baseUrl}&date=${today.getFullYear()}-${today.getMonth()+1}-${today.getDate()}`

  dateInput.addEventListener('change', () => {
    findScheduleLink.href = `${baseUrl}&date=${dateInput.value}`
  })
})
