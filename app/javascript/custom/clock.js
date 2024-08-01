const init = () => {
  const amBtn = document.querySelector('#am-btn')
  const pmBtn = document.querySelector('#pm-btn')
  const active = ['bg-primary', 'text-white', 'active']
  const startedTimeInput = document.querySelector('#order_field_started_time')
  const finishedTimeInput = document.querySelector('#order_field_finished_time')
  const choosingTime = document.querySelector('#choosing-time')
  const amClock = document.querySelector('#am-clock')
  const pmClock = document.querySelector('#pm-clock')
  const currentStart = choosingTime?.querySelector('#start')
  const currentFinish = choosingTime?.querySelector('#finish')
  const amOutsideChoosing = amClock?.querySelector('.outside.choosing')
  const pmOutsideChoosing = pmClock?.querySelector('.outside.choosing')

  amBtn && amBtn.classList.add(...active)
  if (amClock) amClock.style.display = 'block'

  amBtn &&
    amBtn.addEventListener('click', () => {
      amBtn.classList.add(...active)
      pmBtn.classList.remove(...active)

      amClock.style.display = 'block'
      pmClock.style.display = 'none'

      setOutsideChoosing()
    })

  pmBtn &&
    pmBtn.addEventListener('click', () => {
      pmBtn.classList.add(...active)
      amBtn.classList.remove(...active)

      pmClock.style.display = 'block'
      amClock.style.display = 'none'

      setOutsideChoosing()
    })

  startedTimeInput &&
    startedTimeInput.addEventListener('change', () => {
      choosingTime.style.display = 'block'
      currentStart.textContent = startedTimeInput.value
      setOutsideChoosing()
    })

  finishedTimeInput &&
    finishedTimeInput.addEventListener('change', () => {
      choosingTime.style.display = 'block'
      currentFinish.textContent = finishedTimeInput.value
      setOutsideChoosing()
    })

  const setOutsideChoosing = () => {
    let [finishHour, finishMinute] = finishedTimeInput.value
      .split(':')
      .map(Number)
    let [startHour, startMinute] = startedTimeInput.value.split(':').map(Number)
    finishHour = finishHour + finishMinute / 60
    startHour = startHour + startMinute / 60

    if (amClock.style.display == 'block') {
      amOutsideChoosing.style.setProperty(
        '--end',
        finishHour > 12 ? 12 : finishHour
      )
      if (startHour <= 12)
        amOutsideChoosing.style.setProperty('--start', startHour)
    }

    if (pmClock.style.display == 'block') {
      pmOutsideChoosing.style.setProperty(
        '--start',
        startHour <= 12 ? 0 : Math.round((startHour % 12) * 10) / 10
      )
      if (finishHour > 12)
        pmOutsideChoosing.style.setProperty(
          '--end',
          Math.round((finishHour % 12) * 10) / 10
        )
    }
  }
}

document.addEventListener('turbo:load', () => {
  init()
})

document.addEventListener('turbo:frame-load', () => {
  init()
})
