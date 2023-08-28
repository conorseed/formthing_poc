<template>
  <div>
    <div class="w-full" v-if="form && 'ok' in form">
      <template v-if="Object.keys(form.ok.status)[0] == 'active'">
        <h1 class="mb-8 mt-2 text-3xl font-bold tracking-tight text-white sm:text-4xl">
          {{ form.ok.name }}
        </h1>
        <form @submit="encrypt_and_send" class="mb-9 flex flex-col gap-y-6">
          <div>
            <label for="name" class="block text-sm font-medium leading-6 text-white"
              >Name (required)</label
            >
            <div class="mt-2">
              <input
                v-model="form_data.name"
                type="text"
                name="name"
                id="name"
                class="block w-full rounded-md border-0 py-1.5 text-indigo-800 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
                placeholder="John Doe"
                aria-describedby="name-description"
              />
            </div>
            <p class="mt-2 text-sm text-gray-400" id="email-description">
              Please add your full name
            </p>
          </div>
          <div>
            <label for="email" class="block text-sm font-medium leading-6 text-white"
              >Email (required)</label
            >
            <div class="mt-2">
              <input
                v-model="form_data.email"
                type="email"
                name="email"
                id="email"
                class="ring-gray-350 block w-full rounded-md border-0 py-1.5 text-indigo-800 shadow-sm ring-1 ring-inset placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
                placeholder="you@example.com"
                aria-describedby="email-description"
              />
            </div>
            <p class="mt-2 text-sm text-gray-400" id="email-description">
              We'll only use this for spam.
            </p>
          </div>
          <div class="flex gap-2">
            <button
              :disabled="!formIsValid || submit_loading"
              type="submit"
              class="rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 disabled:opacity-30"
            >
              Submit
            </button>
            <div v-if="submit_loading" role="status">
              <svg
                aria-hidden="true"
                class="mr-2 inline h-8 w-8 animate-spin fill-gray-200 text-gray-300 dark:fill-indigo-600 dark:text-gray-400"
                viewBox="0 0 100 101"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  d="M100 50.5908C100 78.2051 77.6142 100.591 50 100.591C22.3858 100.591 0 78.2051 0 50.5908C0 22.9766 22.3858 0.59082 50 0.59082C77.6142 0.59082 100 22.9766 100 50.5908ZM9.08144 50.5908C9.08144 73.1895 27.4013 91.5094 50 91.5094C72.5987 91.5094 90.9186 73.1895 90.9186 50.5908C90.9186 27.9921 72.5987 9.67226 50 9.67226C27.4013 9.67226 9.08144 27.9921 9.08144 50.5908Z"
                  fill="currentColor"
                />
                <path
                  d="M93.9676 39.0409C96.393 38.4038 97.8624 35.9116 97.0079 33.5539C95.2932 28.8227 92.871 24.3692 89.8167 20.348C85.8452 15.1192 80.8826 10.7238 75.2124 7.41289C69.5422 4.10194 63.2754 1.94025 56.7698 1.05124C51.7666 0.367541 46.6976 0.446843 41.7345 1.27873C39.2613 1.69328 37.813 4.19778 38.4501 6.62326C39.0873 9.04874 41.5694 10.4717 44.0505 10.1071C47.8511 9.54855 51.7191 9.52689 55.5402 10.0491C60.8642 10.7766 65.9928 12.5457 70.6331 15.2552C75.2735 17.9648 79.3347 21.5619 82.5849 25.841C84.9175 28.9121 86.7997 32.2913 88.1811 35.8758C89.083 38.2158 91.5421 39.6781 93.9676 39.0409Z"
                  fill="currentFill"
                />
              </svg>
              <span class="sr-only">Loading...</span>
            </div>
          </div>
          <div>
            <div
              class="inline-block rounded bg-red-100 px-3 py-1 text-sm font-bold text-red-600"
              v-for="error in form_submit_errors"
              :key="error"
            >
              {{ error }}
            </div>
          </div>
          <div
            v-if="submit_success"
            class="text-md rounded bg-green-100 p-4 text-center font-bold text-green-600"
          >
            Thanks! We've received your submission.
          </div>
        </form>
      </template>
      <template v-else>
        <h1 class="mb-8 mt-2 text-3xl font-bold tracking-tight text-white sm:text-4xl">
          Form Submissions Closed
        </h1>
        <p class="text-md text-gray-400">
          Submissions for this form are currently closed. Please check back later.
        </p>
      </template>
    </div>
    <div class="w-full" v-if="form && 'err' in form">
      <h1 class="mb-8 mt-2 text-3xl font-bold tracking-tight text-white sm:text-4xl">
        Form Not Found
      </h1>
      <p class="text-md text-gray-400">
        The form you are looking for does not exist. Please check the URL and try again.
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useGeneralUtils } from '@/composables/useGeneralUtils'
import { useVetkdUtils } from '@/composables/useVetkdUtils'
import type { ResultFormReturnPublicWithNonce } from '@root/declarations/form_thing_backend/form_thing_backend.did'
import { computed, ref } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const vetkdUtils = useVetkdUtils()

const { sanitizeHTML } = useGeneralUtils()

// Fetch Form
const form = ref<ResultFormReturnPublicWithNonce>()
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
const submit_loading = ref(false)
const form_submit_errors = ref<string[]>([])
const submit_success = ref(false)
const encrypt_and_send = async (e: Event) => {
  e.preventDefault()
  submit_success.value = false
  form_submit_errors.value = []
  submit_loading.value = true
  try {
    // return early if form is not ready
    if (form.value == null || 'err' in form.value) {
      throw new Error('Form is not ready')
    }

    // public key is not ready
    if (vetkdUtils.key_public.value == null) {
      throw new Error('Could net fetch encryption key')
    }

    // form data is valid
    if (!formIsValid.value) {
      throw new Error('Please fill out all the fields correctly')
    }

    // sanitize form data
    form_data.value.name = sanitizeHTML(form_data.value.name.trim())
    form_data.value.email = form_data.value.email.trim()

    // encrypt form data
    const encrypted_data = await vetkdUtils.aes_encrypt({
      rawKey: vetkdUtils.key_public.value,
      message: JSON.stringify(form_data.value),
      form_id: form.value.ok.id
    })
    if (encrypted_data == null) {
      throw new Error('Failed to encrypt form data')
    }

    // send encrypted data to backend
    const res = await vetkdUtils.form_thing_backend.create_entry(
      form.value.ok.id,
      encrypted_data,
      form.value.ok.nonce
    )

    // form data was successfully submitted
    if ('ok' in res) {
      submit_success.value = true
      form_data.value = {
        name: '',
        email: ''
      }
    } else {
      throw new Error('Something went wrong: ' + res.err)
    }
  } catch (error: any) {
    console.warn(error)
    form_submit_errors.value.push(error.message)
  }
  submit_loading.value = false
}

// formIsValid computed property
const formIsValid = computed(() => {
  if (form_data.value.name.trim() == '' || form_data.value.email.trim() == '') {
    return false
  }
  if (!validateEmail(form_data.value.email.trim())) {
    return false
  }
  return true
})

const validateEmail = (email: string) => {
  return email.match(
    /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
  )
}
</script>
