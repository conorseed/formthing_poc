import type {
  FormReturn,
  FormStatus
} from '@root/declarations/form_thing_backend/form_thing_backend.did'
import { defineStore } from 'pinia'
import { ref } from 'vue'
import { useAuthStore } from './authStore'
import type { Principal } from '@dfinity/principal'

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
    const form = forms.value.find((f) => f.id === formId) as FormReturn
    // return the form
    return form
  }

  // update form settings
  const updateFormSettings = async (
    form_id: string,
    settings: {
      name: string
      status: 'active' | 'inactive'
      users: Principal[]
    }
  ) => {
    // check if actor
    if (!authStore.actor) {
      console.log('no actor')
      return
    }

    // get the form
    const form = await getFormById(form_id)

    // check if form
    if (!form) return

    // make sure status is valid
    const status = { [settings.status]: null } as FormStatus

    console.log('update settings', form.id, settings.name, status, settings.users as Principal[])

    const res = await authStore.actor.update_form_settings(
      form.id,
      settings.name,
      status,
      settings.users as Principal[]
    )
    console.log('update settings res', res)

    if (!res) {
      console.warn('error updating settings')
    }
    if ('err' in res) {
      console.warn('error updating settings', res.err)
    }

    if ('ok' in res) {
      // update form
      form.name = settings.name
      form.status = status
      form.users = settings.users
    }
  }

  return { fetchFormsByUser, getFormById, updateFormSettings, forms }
})
