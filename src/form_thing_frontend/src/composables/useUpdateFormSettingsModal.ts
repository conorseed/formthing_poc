import { useFormStore } from '@/stores/formStore'
import type { Principal } from '@dfinity/principal'
import type { FormReturn } from '@root/declarations/form_thing_backend/form_thing_backend.did'
import { ref } from 'vue'

const formStore = useFormStore()

export function useUpdateFormSettingsModal() {
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
  const onUpdateSettings = async (
    settings: {
      name: string
      status: 'active' | 'inactive'
      users: Principal[]
    }
  ) => {
    console.log('setting update', settings)
    if (!currentForm.value) return
    await formStore.updateFormSettings(currentForm.value.id, settings)
  }

  return { isOpen, currentForm, openModal, onClose, onUpdateSettings }
}
