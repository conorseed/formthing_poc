<template>
  <header class="bg-white">
    <nav
      class="mx-auto flex max-w-7xl items-center justify-between p-6 lg:px-8"
      aria-label="Global"
    >
      <div class="flex lg:flex-1">
        <a href="/" class="-m-1.5 p-1.5 font-bold">
          Form<span class="text-indigo-500">Thing</span>
        </a>
      </div>
      <div class="flex flex-1 justify-end">
        <button
          v-if="!authStore.actor"
          @click="login"
          class="text-sm font-semibold leading-6 text-gray-900"
        >
          Log in <span aria-hidden="true">&rarr;</span>
        </button>
        <button
          v-if="authStore.actor"
          @click="logout"
          class="text-sm font-semibold leading-6 text-gray-900"
        >
          <span aria-hidden="true">&larr;</span>
          Log out ({{ authStore.principal?.toString().substring(0, 5) + '..' }})
        </button>
      </div>
    </nav>
  </header>
</template>

<script setup lang="ts">
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()

const login = async (e: Event) => {
  e.preventDefault()
  await authStore.login()
  console.log('principal', authStore.principal)
  console.log('actor', authStore.actor)
}

const logout = async (e: Event) => {
  e.preventDefault()
  await authStore.logout()
  console.log('logged out')
}
</script>
