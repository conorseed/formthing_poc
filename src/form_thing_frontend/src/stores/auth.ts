import { createActor } from '@root/declarations/form_thing_backend'
import { AuthClient } from '@dfinity/auth-client'
import { HttpAgent, type ActorSubclass, type Identity } from '@dfinity/agent'
import type { _SERVICE } from '@root/declarations/form_thing_backend/form_thing_backend.did.d.ts'
import type { Principal } from '@dfinity/principal'
import { ref } from 'vue'
import { defineStore } from 'pinia'

export const useAuthStore = defineStore('auth', () => {
  // The Internet Identity URL is the URL of the Internet Identity canister on your local network.
  const internet_identity_url = `http://localhost:4943/?canisterId=${
    import.meta.env.CANISTER_ID_INTERNET_IDENTITY
  }`

  // create an actor with an agent that is authenticated with the identity returned by the auth client

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
    actor.value = createActor(import.meta.env.CANISTER_ID_INTERNET_IDENTITY, {
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
  }

  const retry_login = async () => {
    console.log('retry_login')
    // create an auth client
    const authClient = await AuthClient.create()
    const isAuthenticated = await authClient.isAuthenticated()

    if (isAuthenticated) {
      // set identity if authed
      identity.value = authClient.getIdentity()
      // store the principal for ease  if use
      principal.value = identity.value.getPrincipal()
      // Using the identity obtained from the auth client, we can create an agent to interact with the IC.
      agent.value = new HttpAgent({ identity: identity.value })
      // Using the interface description of our webapp, we create an actor that we use to call the service methods.
      actor.value = createActor(import.meta.env.CANISTER_ID_INTERNET_IDENTITY, {
        agent: agent.value
      })
    }
  }

  retry_login()

  // return the store
  return { actor, principal, login, logout }
})

// https://github.com/dfinity/examples/tree/master/motoko/internet_identity_integration
