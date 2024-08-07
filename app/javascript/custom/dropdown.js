document.addEventListener('turbo:load', () => {
  const filterPriceBtn = document.getElementById('filter-price-btn')
  const filterPriceList = document.getElementById('filter-price-list')
  const filterTypeBtn = document.getElementById('filter-type-btn')
  const filterTypeList = document.getElementById('filter-type-list')
  const languageBtn = document.getElementById('language-dropdown-btn')
  const languageMenu = document.getElementById('language-dropdown-menu')
  const statsBtn = document.getElementById('stats-dropdown-btn')
  const statsMenu = document.getElementById('stats-dropdown-menu')
  const ratingContainer = document.getElementById('rating-container')

  if (filterPriceBtn && filterPriceList) {
    dropDown(filterPriceBtn, filterPriceList)
  }

  if (filterTypeBtn && filterTypeList) {
    dropDown(filterTypeBtn, filterTypeList)
  }

  if (languageBtn && languageMenu) {
    dropDown(languageBtn, languageMenu)
  }

  if (statsBtn && statsMenu) {
    dropDown(statsBtn, statsMenu)
  }

  if (ratingContainer) {
    const ratings = Array.from(ratingContainer.children)

    ratings.forEach((rating) => {
      const dropdownBtn = rating.querySelector(`#${rating.id}-dropdown-btn`)
      const dropdownList = rating.querySelector(`#${rating.id}-dropdown-list`)
      dropDown(dropdownBtn, dropdownList)
    })
  }
})

const dropDown = (triggerBtn, dropDownList) => {
  triggerBtn.addEventListener('click', () => {
    dropDownList.classList.toggle('hidden')
  })

  window.addEventListener('click', (event) => {
    if (
      !triggerBtn.contains(event.target) &&
      !dropDownList.contains(event.target)
    ) {
      dropDownList.classList.add('hidden')
    }
  })
}
