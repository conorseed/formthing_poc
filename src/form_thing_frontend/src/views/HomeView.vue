<template>
  <main class="mx-auto max-w-7xl p-6 lg:px-8">
    <section v-if="form && 'ok' in form">
      <h2 class="text-4xl font-bold tracking-tight text-gray-900 sm:text-4xl mb-6">
        {{ form.ok.name }}
      </h2>
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
    </section>
    <section v-else>
      <h2>Form not found</h2>
    </section>
    <section>
      <h2 class="text-4xl font-bold tracking-tight text-gray-900 sm:text-4xl mb-6">Entries</h2>
      <ul role="list" class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
        <li
          v-for="(entry, i) in entries"
          :key="entry.created.toString()"
          class="col-span-1 divide-y divide-gray-200 rounded-lg bg-white shadow p-6"
        >
          <div class="flex justify-between gap-x-4 py-3 text-sm text-gray-500">
            <span>#{{ i }}</span>
            <span>Created: {{ formatDate(entry.created) }}</span>
          </div>
          <div v-if="typeof entry.data === 'object'" class="pt-4">
            <div v-for="(value, key) in entry.data" :key="key">
              <div>{{ key }}: {{ value }}</div>
            </div>
          </div>
          <div v-else>Entry could not be decrypted</div>
        </li>
      </ul>
      <div v-if="!entries || !entries.length">No entries yet.</div>
    </section>
  </main>
</template>

<script setup lang="ts">
import * as agent from '@dfinity/agent'
import * as vetkd from 'ic-vetkd-utils'
import { form_thing_backend } from '@root/declarations/form_thing_backend'
import { ref, computed, watch } from 'vue'
import type {
  Result,
  Result_1,
  EntriesReturn
} from '@root/declarations/form_thing_backend/form_thing_backend.did'

// Get Form ID
const form_id = ref('02vxsx-fa')

// Get Form
const form = ref<Result>()
const form_res = await form_thing_backend.get_form_by_id_with_nonce(form_id.value)
form.value = form_res
console.log('form', form.value)

// if form exists, get the verified encrypted key
const form_key_public = ref<Uint8Array>()
const form_key_derived = ref<Uint8Array>()
if ('ok' in form.value) {
  get_vetkey_public().then((pk) => {
    console.log('public key retrieved:', pk)
    form_key_public.value = pk
    if (!form.value || !('ok' in form.value)) return
    get_vetkey_by_derivation_id(hex_decode(form.value.ok.id)).then((key) => {
      console.log('derived key retrieved:', key)
      form_key_derived.value = key
      get_entries()
    })
  })
}

// else create the form and refresh the page
else {
  await form_thing_backend.create_form('Awesome New Form', '')
  window.location.reload()
}

// setup form data
const form_data = ref({
  name: '',
  email: ''
})

// encrypt and send form data
const encrypted_form_data = ref<string>('')
const encrypt_and_send = async (e: Event) => {
  e.preventDefault()
  // return early if form is not ready
  if (form.value == null || form_key_public.value == null || 'err' in form.value) return

  // encrypt form data
  console.log('encrypting form_data', form_data.value)
  const encrypted_data = await aes_encrypt(JSON.stringify(form_data.value), form_key_public.value)
  if (encrypted_data == null) {
    console.warn('encrypted_data is null')
    return
  }
  encrypted_form_data.value = encrypted_data
  console.log('encrypted_form_data', encrypted_form_data.value)

  // send encrypted data to backend
  const res = await form_thing_backend.create_entry(
    form_id.value,
    encrypted_data,
    form.value.ok.nonce
  )
  console.log('create_entry', res)

  // refresh entries
  get_entries()
}

// get entries
interface EntryDecrypted {
  created: bigint
  data: {
    [key: string]: any
  }
  form_id: string
}
type EntriesDecrypted = Array<EntryDecrypted>

const entries = ref<EntriesDecrypted | EntriesReturn>()
async function get_entries() {
  const res = await form_thing_backend.get_entries(form_id.value)
  // return early if error
  if ('err' in res) {
    console.warn('get_entries', res.err)
    return
  }

  // decrypt entries
  const decrypted_entries = await Promise.all(
    res.ok.map(async (entry) => {
      // return early if form is not ready
      if (form_key_derived.value == null) {
        return {
          ...entry
        }
      }
      console.log('decrypting entry', entry)
      const decrypted_data = await aes_decrypt(entry.data, form_key_derived.value)
      console.log('decrypted_data', decrypted_data)
      return {
        form_id: entry.form_id,
        data: JSON.parse(decrypted_data),
        created: entry.created
      }
    })
  )
  entries.value = decrypted_entries
  console.log('entries retrieved', entries.value)
}

// decrypt form data
const decrypted_form_data = ref()
watch(encrypted_form_data, async (encrypted_data) => {
  if (form_key_derived.value == null) return
  console.log('decrypting')
  const decrypted_data = await aes_decrypt(encrypted_data, form_key_derived.value)
  console.log('decrypted', decrypted_data)
  decrypted_form_data.value = JSON.parse(decrypted_data)
  console.log('decrypted_data', decrypted_form_data.value)
})

/**
 * Helpers
 */

// Convert hex string to Uint8Array
function hex_decode(hexString: string) {
  const match = hexString.match(/.{1,2}/g)
  if (match == null) return new Uint8Array()
  return Uint8Array.from(match.map((byte) => parseInt(byte, 16)))
}
// Convert Uint8Array to hex string
function hex_encode(bytes: Uint8Array) {
  return bytes.reduce((str, byte) => str + byte.toString(16).padStart(2, '0'), '')
}
// Get the verified encrypted key for form_id
async function get_vetkey_by_derivation_id(derivation_id: Uint8Array) {
  // setup transport keys
  const seed = window.crypto.getRandomValues(new Uint8Array(32))
  const tsk = new vetkd.TransportSecretKey(seed)

  // request derived key
  const ek_bytes_hex = await form_thing_backend.vetkd_get_decryption_key(
    derivation_id,
    tsk.public_key()
  )
  // return early if no public key
  if (form_key_public.value == null) return
  console.log('tsk', tsk)
  // verify the key
  const k_bytes = tsk.decrypt(hex_decode(ek_bytes_hex), form_key_public.value, derivation_id)
  return k_bytes
}

// Get the public vetkey
async function get_vetkey_public() {
  const pk_bytes_hex = await form_thing_backend.vetkd_get_public_key()
  return hex_decode(pk_bytes_hex)
}

// Encrypt a string with AES-GCM
async function aes_encrypt(message: string, rawKey: Uint8Array) {
  const message_encoded = new TextEncoder().encode(message)
  const seed = window.crypto.getRandomValues(new Uint8Array(32))

  // return early if form is not ready
  if (!form.value || !('ok' in form.value)) return
  // return early if form_key_public is not ready
  if (!form_key_public.value) return

  const ciphertext = vetkd.IBECiphertext.encrypt(
    form_key_public.value,
    hex_decode(form.value.ok.id),
    message_encoded,
    seed
  )
  return hex_encode(ciphertext.serialize())
}

// Decrypt a string with AES-GCM
async function aes_decrypt(ciphertext_hex: string, rawKey: Uint8Array) {
  console.log('decrypting', ciphertext_hex)
  const ibe_ciphertext = vetkd.IBECiphertext.deserialize(hex_decode(ciphertext_hex))
  console.log('ibe_ciphertext', ibe_ciphertext)
  const ibe_plaintext = ibe_ciphertext.decrypt(rawKey)
  console.log('ibe_plaintext', ibe_plaintext)
  return new TextDecoder().decode(ibe_plaintext)
}

function formatDate(nanoseconds: bigint) {
  let date = new Date(parseInt(nanoseconds.toString()) / 1000000)
  return new Intl.DateTimeFormat('en-US', {
    dateStyle: 'short',
    timeStyle: 'short'
  }).format(date)
}
</script>
