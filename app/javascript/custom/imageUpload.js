import { MAX_IMG_SIZE, IMG_FORMAT } from './constants'

export const validateImg = (imgInput, errorMsg) => {
  const sizeInMb = imgInput.files[0].size / 1024 / 1024
  if (sizeInMb > MAX_IMG_SIZE) {
    alert(errorMsg)
    imgInput.value = ''
  }
}

export const showPreviewImg = (imgInput, previewImg) => {
  const file = imgInput.files[0]
  if (file && IMG_FORMAT.includes(file['type']))
    previewImg.src = URL.createObjectURL(file)
}
