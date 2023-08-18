<template>
  <div>Hello there</div>
</template>

<script setup lang="ts">
import * as vetkd from 'ic-vetkd-utils'
import { form_thing_backend } from '@root/declarations/form_thing_backend'
import { ref, watch } from 'vue'
import {
  type Result,
  type EntriesReturn,
  type FormReturn
} from '@root/declarations/form_thing_backend/form_thing_backend.did'

import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()

const forms = ref<FormReturn[]>([])
const res = await authStore.actor?.get_forms_by_user_principal()
if (res && 'ok' in res) {
  forms.value = res.ok
  console.log('got the forms yo', forms.value)
}

// else create the form and refresh the page
if (!forms.value.length) {
  console.log('creating new form')
  const rand = Math.random().toString(36).substring(4)
  await authStore.actor?.create_form(`Form Thingy ${rand}`, '')
  window.location.reload()
}
</script>
