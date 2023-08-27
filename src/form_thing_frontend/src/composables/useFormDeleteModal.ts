import { useFormStore } from '@/stores/formStore'
import type { FormReturn } from '@root/declarations/form_thing_backend/form_thing_backend.did'
import { ref } from 'vue'

const formStore = useFormStore()

export function useFormDeleteModal() {
  // Setup vars
  const isOpen = ref(false)
  const currentForm = ref<FormReturn | null>(null)

  // Open settings modal
  const openModal = (form: FormReturn) => {
    currentForm.value = form
    isOpen.value = true
  }

  // Close settings modal
  const onClose = () => {
    isOpen.value = false
  }

  // on settings update
  const onConfirmed = async (callback?: Function) => {
    if (!currentForm.value) return
    await formStore.deleteForm(currentForm.value as FormReturn)
    if (callback) callback()
  }

  return { isOpen, currentForm, openModal, onClose, onConfirmed }
}
