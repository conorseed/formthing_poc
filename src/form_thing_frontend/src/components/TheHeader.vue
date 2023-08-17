<template>
  <header class="bg-white">
    <nav
      class="mx-auto flex max-w-7xl items-center justify-between p-6 lg:px-8"
      aria-label="Global"
    >
      <div class="flex lg:flex-1">
        <RouterLink :to="{ name: 'home' }" class="-m-1.5 p-1.5 font-bold">
          Form<span class="text-indigo-500">Thing</span>
        </RouterLink>
      </div>
      <div class="flex flex-1 justify-end">
        <button
          v-if="!authStore.actor"
          @click="login"
          class="text-sm font-semibold leading-6 text-gray-900 px-3 py-1"
        >
          Log in <span aria-hidden="true">&rarr;</span>
        </button>
        <Popover v-if="authStore.actor" class="relative">
          <PopoverButton
            class="inline-flex items-center gap-x-1 text-sm font-semibold leading-6 text-gray-900 px-3 py-1"
          >
            <span>My Account</span>
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
                <div class="p-4">
                  <div
                    v-for="item in resources"
                    :key="item.name"
                    class="group relative flex gap-x-6 rounded-lg p-4 hover:bg-gray-50"
                  >
                    <div
                      class="mt-1 flex h-11 w-11 flex-none items-center justify-center rounded-lg bg-gray-50 group-hover:bg-white"
                    >
                      <component
                        :is="item.icon"
                        class="h-6 w-6 text-gray-600 group-hover:text-indigo-600"
                        aria-hidden="true"
                      />
                    </div>
                    <div>
                      <RouterLink :to="item.to" class="font-semibold text-gray-900">
                        {{ item.name }}
                        <span class="absolute inset-0" />
                      </RouterLink>
                      <p class="mt-1 text-gray-600">{{ item.description }}</p>
                    </div>
                  </div>
                </div>
                <div class="bg-gray-50 p-8">
                  <div class="flex justify-between">
                    <h3 class="text-sm font-semibold leading-6 text-gray-500">Account</h3>
                    <button @click="logout" class="text-sm font-semibold leading-6 text-indigo-600">
                      Log out <span aria-hidden="true">&rarr;</span>
                    </button>
                  </div>
                  <div class="mt-6 space-y-6">
                    <div v-if="authStore.principal">
                      <button
                        @click="copy(authStore.principal.toString(), $event)"
                        type="button"
                        class="text-left flex gap-2 group"
                      >
                        <DocumentDuplicateIcon
                          v-if="!copied"
                          class="h-5 w-5 text-gray-600 group-hover:text-indigo-600"
                        />
                        <CheckIcon v-else class="h-5 w-5 text-green-500" />
                        <span class="text-xs">{{ authStore.principal?.toString() }}</span>
                      </button>
                    </div>
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
import { useAuthStore } from '@/stores/auth'
import { useRouter } from 'vue-router'

const router = useRouter()
const authStore = useAuthStore()

const resources = [
  {
    name: 'Forms',
    description: 'View all forms you have access to',
    to: 'account',
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
    router.push({ name: 'account' })
  }
}

const logout = async (e: Event) => {
  e.preventDefault()
  await authStore.logout()
  router.push({ name: 'home' })
}
</script>
