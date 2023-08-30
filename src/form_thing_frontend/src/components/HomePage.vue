<template>
  <div>
    <!-- Hero section -->
    <div class="relative py-16">
      <div
        class="absolute inset-x-0 -top-40 -z-10 transform-gpu overflow-hidden blur-3xl sm:-top-80"
        aria-hidden="true"
      >
        <div
          class="relative left-[calc(50%-11rem)] aspect-[1155/678] w-[36.125rem] -translate-x-1/2 rotate-[30deg] bg-gradient-to-tr from-[#ff80b5] to-[#9089fc] opacity-30 sm:left-[calc(50%-30rem)] sm:w-[72.1875rem]"
          style="
            clip-path: polygon(
              74.1% 44.1%,
              100% 61.6%,
              97.5% 26.9%,
              85.5% 0.1%,
              80.7% 2%,
              72.5% 32.5%,
              60.2% 62.4%,
              52.4% 68.1%,
              47.5% 58.3%,
              45.2% 34.5%,
              27.5% 76.7%,
              0.1% 64.9%,
              17.9% 100%,
              27.6% 76.8%,
              76.1% 97.7%,
              74.1% 44.1%
            );
          "
        />
      </div>
      <div class="mx-auto max-w-7xl px-6 lg:px-8">
        <div class="mx-auto max-w-2xl text-center">
          <h1 class="text-4xl font-bold tracking-tight text-gray-900 sm:text-6xl">
            End to End Encrypted Forms on the Blockchain
          </h1>
          <p class="mt-6 text-lg leading-8 text-gray-600">
            Build beautiful, accessible forms on the IC with End-to-End Encryption where it counts.
            Because protecting your data should be effortless.
          </p>
          <div class="mt-10 flex items-center justify-center gap-x-6">
            <button
              v-if="!authStore.actor"
              type="button"
              @click="login"
              class="rounded-md bg-indigo-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
            >
              Get started
            </button>
            <RouterLink
              v-else
              :to="{ name: 'admin' }"
              class="rounded-md bg-indigo-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
            >
              Go To Forms
            </RouterLink>
            <a
              target="_blank"
              href="https://github.com/conorseed/formthing_poc#"
              class="text-sm font-semibold leading-6 text-gray-900"
              >Learn more <span aria-hidden="true">→</span></a
            >
          </div>
        </div>
        <div class="mt-16 flow-root sm:mt-24">
          <div
            class="-m-2 rounded-xl bg-gray-900/5 p-2 ring-1 ring-inset ring-gray-900/10 lg:-m-4 lg:rounded-2xl lg:p-4"
          >
            <img
              src="/images/screenshot.jpg"
              alt="App screenshot"
              width="2432"
              height="1442"
              class="rounded-md shadow-2xl ring-1 ring-gray-900/10"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useAuthStore } from '@/stores/authStore'
import { useNotificationStore } from '@/stores/useNotificationStore'
import { useRouter } from 'vue-router'

const authStore = useAuthStore()
const router = useRouter()
const notificationStore = useNotificationStore()

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
</script>
