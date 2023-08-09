<template>
  <main>
    <h2>Home Page</h2>
    <form>
      <div>
        <label for="name" class="block text-sm font-medium leading-6 text-gray-900">Name</label>
        <div class="mt-2">
          <input
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
  </main>
</template>

<script setup lang="ts">
import * as agent from '@dfinity/agent'
import * as vetkd from 'ic-vetkd-utils'
import { form_thing_backend } from '../../../declarations/form_thing_backend'

// const testing = async () => {
//   console.log('testing')
//   const res = await form_thing_backend.create_form('Name Goes Here', 'idgoeshere')
//   console.log('res', res)
// }
// testing()

const get_vetkey_by_derivation_id = async (derivation_id: Uint8Array) => {
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

  console.log('the verified decrypted key:', hex_encode(the_key))
}
get_vetkey_by_derivation_id(hex_decode('idgoeshere'))

/**
 * Helpers
 */
function hex_decode(hexString) {
  return Uint8Array.from(hexString.match(/.{1,2}/g).map((byte) => parseInt(byte, 16)))
}
function hex_encode(bytes) {
  return bytes.reduce((str, byte) => str + byte.toString(16).padStart(2, '0'), '')
}
</script>
