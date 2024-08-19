document.addEventListener('turbo:load', () => {
  const option = document.getElementById('unavailable-schedule-option')
  const timeInputBlocks = document.querySelectorAll('.choose-schedule-time')
  const startTimeInput = document.getElementById(
    'unavailable_field_schedule_started_time'
  )
  const finishTimeInput = document.getElementById(
    'unavailable_field_schedule_finished_time'
  )

  if (option && startTimeInput?.value && finishTimeInput?.value) {
    const startTime = startTimeInput.value
    const finishTime = finishTimeInput.value
    const beginOfDay = '00:00'
    const endOfDay = '23:59'

    if (startTime == beginOfDay && finishTime == endOfDay) {
      option.value = 'all'
    } else {
      option.value = 'include_time'
    }

    timeInputBlocks.forEach((inputBlock) => {
      inputBlock.classList.remove('hidden')
    })
  }

  option &&
    option.addEventListener('change', () => {
      if (option.value == 'include_time') {
        timeInputBlocks.forEach((inputBlock) => {
          inputBlock.classList.remove('hidden')
        })
      } else {
        timeInputBlocks.forEach((inputBlock) => {
          inputBlock.classList.add('hidden')
        })
      }
    })
})
