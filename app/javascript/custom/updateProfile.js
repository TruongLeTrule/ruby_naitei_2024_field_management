import { validateImg, showPreviewImg } from './imageUpload'

document.addEventListener('turbo:load', () => {
  const imgInput = document.getElementById('user_image')
  const previewImg = document.getElementById('preview-profile-img')

  imgInput &&
    imgInput.addEventListener('change', () => {
      validateImg(imgInput, I18n.t('js.errors.img_too_large'))
      showPreviewImg(imgInput, previewImg)
    })
})
