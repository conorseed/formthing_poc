import type { FormReturn } from '@root/declarations/form_thing_backend/form_thing_backend.did'
import { defineStore } from 'pinia'
import { ref } from 'vue'
import { useAuthStore } from './authStore'

export const useFormStore = defineStore('form', () => {
  /*
   * Main store values
   */
  const forms = ref<FormReturn[]>([])

  // useful variables
  const authStore = useAuthStore()

  // function to get all forms
  const fetchFormsByUser = async () => {
    // fetch the forms
    const res = await authStore.actor?.get_forms_by_user_principal()
    // set the forms
    if (res && 'ok' in res) {
      forms.value = res.ok
    }

    return forms.value
  }

  // get form by id
  const getFormById = async (formId: string) => {
    // check if we have forms
    if (!forms.value.length) {
      const res = await fetchFormsByUser()
      if (!res.length) return undefined
    }
    // get the form
    const form = forms.value.find((f) => f.id === formId)
    // return the form
    return form
  }

  return { fetchFormsByUser, getFormById, forms }
})
