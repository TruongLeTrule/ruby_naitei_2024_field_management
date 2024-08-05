document.addEventListener('turbo:load', () => {
  const dropdownButtons = document.getElementsByClassName('dropdownButton');
  const dropdownMenus = document.getElementsByClassName('dropdownMenu');

  if (dropdownButtons.length > 0 && dropdownMenus.length > 0) {
    Array.from(dropdownButtons).forEach((button, index) => {
      const menu = dropdownMenus[index];

      button.addEventListener('click', (event) => {
        event.stopPropagation();
        menu.classList.toggle('hidden');
      });
    });

    window.addEventListener('click', () => {
      Array.from(dropdownMenus).forEach(menu => {
        menu.classList.add('hidden');
      });
    });
  }
});
