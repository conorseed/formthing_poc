<template>
  <main>
    <section v-if="form && 'ok' in form">
      <h2>{{ form.ok.name }}</h2>
      <form @submit="encrypt_and_send">
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
        <button
          type="submit"
          class="rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
        >
          Submit
        </button>
      </form>
    </section>
    <section v-else>
      <h2>Form not found</h2>
    </section>
  </main>
</template>

<script setup lang="ts">
import * as agent from '@dfinity/agent'
import * as vetkd from 'ic-vetkd-utils'
import { form_thing_backend } from '@root/declarations/form_thing_backend'
import { ref, computed, watch } from 'vue'
import type { Result } from '@root/declarations/form_thing_backend/form_thing_backend.did'

// Get Form ID
const form_id = ref('02vxsx-fa')

// Get Form
const form = ref<Result>()
const form_res: Result = await form_thing_backend.get_form_by_id(form_id.value)
form.value = form_res
console.log('form', form.value)

// if form exists, get the verified encrypted key
const form_key = ref<Uint8Array>()
if ('ok' in form.value) {
  form_key.value = await get_vetkey_by_derivation_id(hex_decode(form_id.value))
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
  if (form.value == null || form_key.value == null) return
  console.log('encrypting form_data', form_data.value)
  const encrypted_data = await aes_gcm_encrypt(JSON.stringify(form_data.value), form_key.value)
  encrypted_form_data.value = encrypted_data
  console.log('encrypted_form_data', encrypted_form_data.value)
  // const res = await form_thing_backend.submit_form_data(form_id.value, encrypted_data)
}

// decrypt form data
const decrypted_form_data = ref()
watch(encrypted_form_data, async (encrypted_data) => {
  if (form_key.value == null) return
  console.log('decrypting')
  const decrypted_data = await aes_gcm_decrypt(encrypted_data, form_key.value)
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
  const seed = window.crypto.getRandomValues(new Uint8Array(32))
  const tsk = new vetkd.TransportSecretKey(seed)
  const ek_bytes_hex = await form_thing_backend.vetkd_get_symmetric_key(
    derivation_id,
    tsk.public_key()
  )
  const pk_bytes_hex = await form_thing_backend.vetkd_get_public_key()
  const the_key = await tsk.decrypt_and_hash(
    hex_decode(ek_bytes_hex),
    hex_decode(pk_bytes_hex),
    derivation_id,
    32,
    new TextEncoder().encode('aes-256-gcm')
  )
  return the_key
}

// Encrypt a string with AES-GCM
async function aes_gcm_encrypt(message: string, rawKey: Uint8Array) {
  const iv = window.crypto.getRandomValues(new Uint8Array(12)) // 96-bits; unique per message
  const aes_key = await window.crypto.subtle.importKey('raw', rawKey, 'AES-GCM', false, ['encrypt'])
  const message_encoded = new TextEncoder().encode(message)
  const ciphertext_buffer = await window.crypto.subtle.encrypt(
    { name: 'AES-GCM', iv: iv },
    aes_key,
    message_encoded
  )
  const ciphertext = new Uint8Array(ciphertext_buffer)
  var iv_and_ciphertext = new Uint8Array(iv.length + ciphertext.length)
  iv_and_ciphertext.set(iv, 0)
  iv_and_ciphertext.set(ciphertext, iv.length)
  return hex_encode(iv_and_ciphertext)
}

// Decrypt a string with AES-GCM
async function aes_gcm_decrypt(ciphertext_hex: string, rawKey: Uint8Array) {
  const iv_and_ciphertext = hex_decode(ciphertext_hex)
  const iv = iv_and_ciphertext.subarray(0, 12) // 96-bits; unique per message
  const ciphertext = iv_and_ciphertext.subarray(12)
  const aes_key = await window.crypto.subtle.importKey('raw', rawKey, 'AES-GCM', false, ['decrypt'])
  let decrypted = await window.crypto.subtle.decrypt(
    { name: 'AES-GCM', iv: iv },
    aes_key,
    ciphertext
  )
  return new TextDecoder().decode(decrypted)
}
</script>
