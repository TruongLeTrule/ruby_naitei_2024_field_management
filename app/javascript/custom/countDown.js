document.addEventListener('turbo:load', () => {
  const countDown = document.getElementById('count-down-container')
  const startTime = countDown?.dataset.createdAt * 1000
  const duration = countDown?.dataset.duration * 1000

  countDown && startCountdown(startTime, duration)
})

function startCountdown(startTime, duration) {
  const countdownElement = document.getElementById('count-down-clock')

  function updateCountdown() {
    const now = new Date().getTime()
    const endTime = startTime + duration
    const timeRemaining = endTime - now

    if (timeRemaining <= 0) {
      clearInterval(interval)
      return
    }

    const minutes = Math.floor((timeRemaining % (1000 * 60 * 60)) / (1000 * 60))
    const seconds = Math.floor((timeRemaining % (1000 * 60)) / 1000)

    countdownElement.textContent = `${minutes}:${seconds}`
  }

  const interval = setInterval(updateCountdown, 1000)
}
