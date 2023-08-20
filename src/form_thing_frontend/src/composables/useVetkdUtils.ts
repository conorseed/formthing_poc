import { ref } from 'vue'
import * as vetkd from 'ic-vetkd-utils'
import { form_thing_backend } from '@root/declarations/form_thing_backend'
import { useAuthStore } from '@/stores/authStore'

export function useVetkdUtils() {
  const key_public = ref<Uint8Array | null>(null)
  const key_derived = ref<Uint8Array | null>(null)

  // get both keys
  const fetch_vetkeys = async (form_id: string) => {
    // fetch and set the public key
    const key_public_promise = await fetch_vetkey_public()
    if (!key_public_promise) {
      console.warn('Could not fetch public key')
      return null
    }

    // get derivation id
    const derivation_id = string_to_bytes(form_id)
    if (!derivation_id) {
      console.warn('Could not decode derivation id')
      return null
    }

    // fetch and set the derived key
    const key_derived_promise = await fetch_vetkey_by_derivation_id(derivation_id)
    if (!key_derived_promise) {
      console.warn('Could not fetch derived key')
      return null
    }

    return { key_public, key_derived }
  }

  // Get the public vetkey
  const fetch_vetkey_public = async () => {
    const pk_bytes_hex = await form_thing_backend.vetkd_get_public_key()
    if (!pk_bytes_hex) return null
    key_public.value = hex_decode(pk_bytes_hex)
    return hex_decode(pk_bytes_hex)
  }

  // Get the verified encrypted key for form_id
  const fetch_vetkey_by_derivation_id = async (derivation_id: Uint8Array) => {
    // setup transport keys
    const seed = window.crypto.getRandomValues(new Uint8Array(32))
    const tsk = new vetkd.TransportSecretKey(seed)

    // request derived key
    const ek_bytes_hex = await useAuthStore().actor?.vetkd_get_decryption_key(
      derivation_id,
      tsk.public_key()
    )
    // return early if no public key
    if (key_public.value == null) return

    // return early if no encrypted key
    if (!ek_bytes_hex || 'err' in ek_bytes_hex) return

    // encrypted_key_bytes
    const ek_bytes = hex_decode(ek_bytes_hex.ok)
    if (!ek_bytes) return

    // verify the key
    const k_bytes = tsk.decrypt(ek_bytes, key_public.value, derivation_id)

    if (k_bytes != null) {
      key_derived.value = k_bytes
    }
    return k_bytes
  }

  // Convert hex string to Uint8Array
  const hex_decode = (hexString: string) => {
    const match = hexString.match(/.{1,2}/g)
    if (match == null) return null
    const hex_array = Uint8Array.from(match.map((byte) => parseInt(byte, 16)))
    return hex_array
  }

  // Convert Uint8Array to hex string
  const hex_encode = (bytes: Uint8Array) => {
    return bytes.reduce((str, byte) => str + byte.toString(16).padStart(2, '0'), '')
  }

  // convert a string to Uint8Array
  const string_to_bytes = (str: string) => {
    return new TextEncoder().encode(str)
  }

  const aes_encrypt = ({
    message,
    rawKey,
    form_id
  }: {
    message: string
    rawKey: Uint8Array
    form_id: string
  }) => {
    const message_encoded = new TextEncoder().encode(message)
    const seed = window.crypto.getRandomValues(new Uint8Array(32))

    // return early if form is not ready
    if (!form_id) return

    const derivation_id = string_to_bytes(form_id)
    if (!derivation_id) return

    const ciphertext = vetkd.IBECiphertext.encrypt(rawKey, derivation_id, message_encoded, seed)
    return hex_encode(ciphertext.serialize())
  }

  // Decrypt a string with AES-GCM
  const aes_decrypt = async ({
    ciphertext_hex,
    rawKey
  }: {
    ciphertext_hex: string
    rawKey: Uint8Array
  }) => {
    const bytes = hex_decode(ciphertext_hex)
    if (!bytes) return
    const ibe_ciphertext = vetkd.IBECiphertext.deserialize(bytes)
    const ibe_plaintext = ibe_ciphertext.decrypt(rawKey)
    return new TextDecoder().decode(ibe_plaintext)
  }

  return {
    fetch_vetkeys,
    fetch_vetkey_public,
    aes_encrypt,
    aes_decrypt,
    vetkd,
    form_thing_backend,
    key_derived,
    key_public
  }
}
