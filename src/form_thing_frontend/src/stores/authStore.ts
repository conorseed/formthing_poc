import { createActor } from '@root/declarations/form_thing_backend'
import { AuthClient } from '@dfinity/auth-client'
import { HttpAgent, type ActorSubclass, type Identity } from '@dfinity/agent'
import type { _SERVICE } from '@root/declarations/form_thing_backend/form_thing_backend.did.d.ts'
import type { Principal } from '@dfinity/principal'
import { ref } from 'vue'
import { defineStore } from 'pinia'
import { useFormStore } from '@/stores/formStore'

export const useAuthStore = defineStore('auth', () => {
  // The Internet Identity URL is the URL of the Internet Identity canister on your local network.
  const internet_identity_url =
    import.meta.env.DFX_NETWORK == 'local'
      ? `http://localhost:4943/?canisterId=${import.meta.env.CANISTER_ID_INTERNET_IDENTITY}`
      : `https://identity.ic0.app`

  /*
   * Main store values
   */
  const actor = ref<ActorSubclass<_SERVICE> | null>(null)
  const identity = ref<Identity | null>(null)
  const principal = ref<Principal | null>(null)
  const agent = ref<HttpAgent | null>(null)

  // A function to login using the Internet Identity canister.
  const login = async () => {
    // create an auth client
    const authClient = await AuthClient.create()

    // start the login process and wait for it to finish
    await new Promise<void>((resolve) => {
      authClient.login({
        identityProvider: internet_identity_url,
        onSuccess: resolve
      })
    })

    // At this point we're authenticated, and we can get the identity from the auth client:
    identity.value = authClient.getIdentity()
    // store the principal for ease  if use
    principal.value = identity.value.getPrincipal()
    // Using the identity obtained from the auth client, we can create an agent to interact with the IC.
    agent.value = new HttpAgent({ identity: identity.value })
    // Using the interface description of our webapp, we create an actor that we use to call the service methods.
    actor.value = createActor(import.meta.env.CANISTER_ID_FORM_THING_BACKEND, {
      agent: agent.value
    })

    return false
  }

  const logout = async () => {
    // create an auth client
    const authClient = await AuthClient.create()

    // logout with the auth client
    await authClient.logout()

    // set all the values to null
    actor.value = null
    identity.value = null
    principal.value = null
    agent.value = null

    // clear form store
    useFormStore().clear()
  }

  const login_retry = async () => {
    console.log('retry_login')

    const authClient = await AuthClient.create()

    if (!(await isAuthenticated())) return false

    // set identity if authed
    identity.value = authClient.getIdentity()
    // store the principal for ease  if use
    principal.value = identity.value.getPrincipal()
    // Using the identity obtained from the auth client, we can create an agent to interact with the IC.
    agent.value = new HttpAgent({ identity: identity.value })
    // Using the interface description of our webapp, we create an actor that we use to call the service methods.
    actor.value = createActor(import.meta.env.CANISTER_ID_FORM_THING_BACKEND, {
      agent: agent.value
    })

    return true
  }

  // A function to check if the user is authenticated
  const isAuthenticated = async (authClient?: AuthClient | null) => {
    if (!authClient) {
      authClient = await AuthClient.create()
    }
    const isAuthenticated = await authClient.isAuthenticated()
    return isAuthenticated
  }

  // return the store
  return { actor, principal, login, logout, login_retry, isAuthenticated }
})
