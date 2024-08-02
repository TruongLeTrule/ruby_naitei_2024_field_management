document.addEventListener('turbo:load', () => {
  const voucherSelect = document.getElementById('order_field_voucher_id')
  const voucherApply = document.getElementById('voucher-apply')
  const baseUrl = voucherApply.getAttribute('href')
  const inactive = [
    'cursor-not-allowed',
    'pointer-events-none',
    'text-gray-500',
    'inactive',
  ]
  const active = ['text-primary', 'underline', 'active']

  const disableLink = () => {
    voucherApply.classList.remove(...active)
    voucherApply.classList.add(...inactive)
  }

  const enableLink = () => {
    voucherApply.classList.remove(...inactive)
    voucherApply.classList.add(...active)
  }

  voucherSelect &&
    voucherSelect.addEventListener('change', () => {
      voucherApply.setAttribute(
        'href',
        `${baseUrl}&voucher_id=${voucherSelect.value}`
      )

      voucherSelect.value == 0 ? disableLink() : enableLink()
    })

  voucherSelect.value == 0 ? disableLink() : enableLink()
})
