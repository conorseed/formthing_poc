import { useFormStore } from '@/stores/formStore'
import { useNotificationStore } from '@/stores/useNotificationStore'
import type { FormReturn } from '@root/declarations/form_thing_backend/form_thing_backend.did.d.ts'
import { ref } from 'vue'

const formStore = useFormStore()
const notificationStore = useNotificationStore()

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
    // create notification so user knows something is happening
    const nid = notificationStore.addNotification({
      title: 'Deleting form',
      message: 'Please wait...',
      status: 'loading'
    })

    try {
      // check if form is selected
      if (!currentForm.value) throw new Error('No form selected')

      // delete form
      const form_id = currentForm.value.id
      await formStore.deleteForm(currentForm.value as FormReturn)

      // update notification
      notificationStore.updateNotification(nid, {
        title: 'Form deleted',
        message: `Form (${form_id}) deleted`,
        status: 'success'
      })

      // callback
      if (callback) callback()
    } catch (e: any) {
      notificationStore.updateNotification(nid, {
        title: 'Error deleting form',
        message: e.message,
        status: 'error'
      })
    }
  }

  return { isOpen, currentForm, openModal, onClose, onConfirmed }
}
