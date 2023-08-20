<template>
  <div>
    <form @submit="encrypt_and_send" class="flex gap-y-4 flex-col mb-9">
      <div>
        <label for="name" class="block text-sm font-medium leading-6 text-gray-900">Name</label>
        <div class="mt-2">
          <input
            v-model="form_data.name"
            type="text"
            name="name"
            id="name"
            class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
            placeholder="John Doe"
            aria-describedby="name-description"
          />
        </div>
        <p class="mt-2 text-sm text-gray-500" id="email-description">Please add your full name</p>
      </div>
      <div>
        <label for="email" class="block text-sm font-medium leading-6 text-gray-900">Email</label>
        <div class="mt-2">
          <input
            v-model="form_data.email"
            type="email"
            name="email"
            id="email"
            class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
            placeholder="you@example.com"
            aria-describedby="email-description"
          />
        </div>
        <p class="mt-2 text-sm text-gray-500" id="email-description">
          We'll only use this for spam.
        </p>
      </div>
      <div>
        <button
          type="submit"
          class="rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
        >
          Submit
        </button>
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { useVetkdUtils } from '@/composables/useVetkdUtils'
import type { Result_1 } from '@root/declarations/form_thing_backend/form_thing_backend.did'
import { ref } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const vetkdUtils = useVetkdUtils()

// Fetch Form
const form = ref<Result_1>()
const form_res = await vetkdUtils.form_thing_backend.get_form_by_id_with_nonce(
  route.params.formId as string
)
form.value = form_res

// if form exists, get the public key quietly
if ('ok' in form.value) {
  vetkdUtils.fetch_vetkey_public()
}

// setup form data
const form_data = ref({
  name: '',
  email: ''
})

// encrypt and send form data
const encrypt_and_send = async (e: Event) => {
  e.preventDefault()
  // return early if form is not ready
  if (form.value == null || vetkdUtils.key_public.value == null || 'err' in form.value) {
    console.warn('form is not ready')
    return
  }

  // encrypt form data
  console.log('encrypting form_data', form_data.value)
  const encrypted_data = await vetkdUtils.aes_encrypt({
    rawKey: vetkdUtils.key_public.value,
    message: JSON.stringify(form_data.value),
    form_id: form.value.ok.id
  })
  if (encrypted_data == null) {
    console.warn('encrypted_data is null')
    return
  }

  // send encrypted data to backend
  const res = await vetkdUtils.form_thing_backend.create_entry(
    form.value.ok.id,
    encrypted_data,
    form.value.ok.nonce
  )
  console.log('create_entry', res)
}
</script>
