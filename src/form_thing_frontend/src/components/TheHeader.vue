<template>
  <header class="bg-indigo-950">
    <nav
      class="mx-auto flex max-w-7xl items-center justify-between p-6 lg:px-8"
      aria-label="Global"
    >
      <div class="flex">
        <RouterLink :to="{ name: 'home' }" class="-m-1.5 p-1.5 font-bold text-white">
          Form<span class="text-indigo-400">Thing</span>
        </RouterLink>
      </div>
      <div v-if="authStore.actor" class="hidden justify-center md:flex">
        <div class="ml-10 flex items-baseline space-x-4">
          <RouterLink
            v-for="item in navigation"
            :key="item.name"
            :to="item.to"
            :class="[
              router.currentRoute.value.name == item.to.name
                ? 'text-white underline underline-offset-8'
                : 'text-gray-400 hover:text-white hover:underline hover:underline-offset-8',
              'rounded-md px-3 py-2 text-sm font-medium transition-all'
            ]"
            :aria-current="router.currentRoute.value.name == item.to.name ? 'page' : undefined"
            >{{ item.name }}</RouterLink
          >
        </div>
      </div>
      <div class="flex justify-end">
        <button
          v-if="!authStore.actor"
          @click="login"
          class="px-3 py-2 text-sm font-semibold leading-6 text-white"
        >
          Log in <span aria-hidden="true">&rarr;</span>
        </button>
        <Popover v-if="authStore.actor" class="relative">
          <PopoverButton
            class="inline-flex items-center gap-x-1 px-3 py-2 text-sm font-semibold leading-6 text-white"
          >
            <span>Account</span>
            <ChevronDownIcon class="h-5 w-5" aria-hidden="true" />
          </PopoverButton>

          <transition
            enter-active-class="transition ease-out duration-200"
            enter-from-class="opacity-0 translate-y-1"
            enter-to-class="opacity-100 translate-y-0"
            leave-active-class="transition ease-in duration-150"
            leave-from-class="opacity-100 translate-y-0"
            leave-to-class="opacity-0 translate-y-1"
          >
            <PopoverPanel class="absolute right-0 z-10 mt-5 flex w-screen max-w-max">
              <div
                class="w-screen max-w-md flex-auto overflow-hidden rounded-3xl bg-white text-sm leading-6 shadow-lg ring-1 ring-gray-900/5"
              >
                <div class="bg-gray-50 p-8">
                  <div class="flex justify-between gap-2">
                    <div v-if="authStore.principal">
                      <button
                        @click="copy(authStore.principal.toString(), $event)"
                        type="button"
                        class="group flex gap-2 text-left"
                      >
                        <DocumentDuplicateIcon
                          v-if="!copied"
                          class="h-5 w-5 text-gray-600 group-hover:text-indigo-600"
                        />
                        <CheckIcon v-else class="h-5 w-5 text-green-500" />
                        <span class="text-xs">{{ authStore.principal?.toString() }}</span>
                      </button>
                    </div>
                    <button
                      @click="logout"
                      class="flex-shrink-0 text-sm font-semibold leading-6 text-indigo-600"
                    >
                      Log out <span aria-hidden="true">&rarr;</span>
                    </button>
                  </div>
                </div>
              </div>
            </PopoverPanel>
          </transition>
        </Popover>
      </div>
    </nav>
  </header>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { Popover, PopoverButton, PopoverPanel } from '@headlessui/vue'
import { ChevronDownIcon } from '@heroicons/vue/20/solid'
import { PencilSquareIcon, DocumentDuplicateIcon, CheckIcon } from '@heroicons/vue/24/outline'
import { useAuthStore } from '@/stores/authStore'
import { useRouter } from 'vue-router'

const router = useRouter()
const authStore = useAuthStore()

const navigation = [
  {
    name: 'Forms',
    description: 'View all forms you have access to',
    to: { name: 'admin' },
    icon: PencilSquareIcon
  }
]

const copied = ref(false)
const copy = (input: string, e: Event) => {
  e.preventDefault()
  copied.value = true
  navigator.clipboard.writeText(input)
  setTimeout(() => {
    copied.value = false
  }, 2000)
}

const login = async (e: Event) => {
  e.preventDefault()
  await authStore.login()
  if (await authStore.isAuthenticated()) {
    router.push({ name: 'admin' })
  }
}

const logout = async (e: Event) => {
  e.preventDefault()
  await authStore.logout()
  router.push({ name: 'home' })
}
</script>
@/stores/authStore
