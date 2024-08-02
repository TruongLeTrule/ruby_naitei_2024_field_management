document.addEventListener('turbo:load', () => {
  const dropdownBtn = document.getElementById('dropdownButton')
  const dropdownMenu = document.getElementById('dropdownMenu')
  const filterPriceBtn = document.getElementById('filter-price-btn')
  const filterPriceList = document.getElementById('filter-price-list')
  const filterTypeBtn = document.getElementById('filter-type-btn')
  const filterTypeList = document.getElementById('filter-type-list')
  const languageBtn = document.getElementById('language-dropdown-btn')
  const languageMenu = document.getElementById('language-dropdown-menu')
  const statsBtn = document.getElementById('stats-dropdown-btn')
  const statsMenu = document.getElementById('stats-dropdown-menu')

  if (dropdownBtn && dropdownMenu) {
    dropDown(dropdownBtn, dropdownMenu)
  }

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
