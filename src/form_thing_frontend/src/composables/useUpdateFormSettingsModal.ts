import { useFormStore } from '@/stores/formStore'
import { useNotificationStore } from '@/stores/useNotificationStore'
import type { Principal } from '@dfinity/principal'
import type { FormReturn } from '@root/declarations/form_thing_backend/form_thing_backend.did'
import { ref } from 'vue'

const formStore = useFormStore()
const notificationStore = useNotificationStore()

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
    // setup notification so user knows something is happening
    const nid = notificationStore.addNotification({
      title: 'Updating form settings',
      message: 'Please wait...',
      status: 'loading'
    })

    try {
      // check if form is selected
      if (!currentForm.value) throw new Error('No form selected')

      // update form settings
      const form_id = currentForm.value.id
      await formStore.updateFormSettings(form_id, settings)

      // update notification
      notificationStore.updateNotification(nid, {
        title: 'Settings updated',
        message: `Settings for form (${form_id}) updated`,
        status: 'success'
      })
    } catch (e: any) {
      notificationStore.updateNotification(nid, {
        title: 'Error updating settings',
        message: e.message,
        status: 'error'
      })
    }
  }

  return { isOpen, currentForm, openModal, onClose, onUpdateSettings }
}
