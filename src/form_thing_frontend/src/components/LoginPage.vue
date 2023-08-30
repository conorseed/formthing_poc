<template>
  <div class="flex min-h-screen flex-col py-6">
    <h1 class="mb-6 text-center text-4xl font-bold tracking-tight text-gray-900 sm:text-4xl">
      Please Login
    </h1>
    <div class="text-center">
      <button
        v-if="!authStore.actor"
        type="button"
        @click="login"
        class="rounded-md bg-indigo-600 px-3.5 py-2.5 text-xl font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
      >
        Log in
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useAuthStore } from '@/stores/authStore'
import { useNotificationStore } from '@/stores/useNotificationStore'
import { useRouter } from 'vue-router'
import { useSeoMeta } from '@vueuse/head'

const authStore = useAuthStore()
const router = useRouter()
const notificationStore = useNotificationStore()

if (await authStore.isAuthenticated()) {
  router.push({ name: 'admin' })
}

const login = async (e: Event) => {
  e.preventDefault()

  try {
    await authStore.login()
    if (await authStore.isAuthenticated()) {
      // add notification to the user
      notificationStore.addNotification({
        title: 'Login Success!',
        message: 'You are now logged in',
        status: 'success'
      })
      // redirect to admin page
      router.push({ name: 'admin' })
    }
  } catch (e: any) {
    // add notification to the user
    notificationStore.addNotification({
      title: 'Login Failed',
      message: e.message,
      status: 'error'
    })
  }
}

/*
 * SEO
 */
useSeoMeta({
  title: 'Log in'
})
</script>
