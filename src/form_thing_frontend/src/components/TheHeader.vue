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
      <div v-if="authStore.actor" class="hidden justify-center lg:flex">
        <div class="ml-10 flex items-center space-x-4">
          <RouterLink
            v-for="item in navigation"
            :key="item.name"
            :to="item.to"
            :class="[
              router.currentRoute.value.name == item.to.name
                ? 'text-white underline underline-offset-8'
                : 'text-gray-400 hover:text-white hover:underline hover:underline-offset-8',
              'group flex gap-2 rounded-md px-3 py-2 text-sm font-medium transition-all'
            ]"
            :aria-current="router.currentRoute.value.name == item.to.name ? 'page' : undefined"
          >
            <component
              v-if="item.icon"
              :is="item.icon"
              class="h-5 w-5 flex-none"
              aria-hidden="true"
            />
            {{ item.name }}</RouterLink
          >
        </div>
      </div>
      <div class="hidden justify-end lg:flex">
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
      <!--MOBILE MENU-->
      <div class="flex justify-end lg:hidden">
        <button
          type="button"
          class="-m-2.5 inline-flex items-center justify-center rounded-md p-2.5 text-white lg:hidden"
          @click="mobileMenuOpen = true"
        >
          <span class="sr-only">Open main menu</span>
          <Bars3Icon class="h-6 w-6" aria-hidden="true" />
        </button>
        <Dialog as="div" class="" @close="mobileMenuOpen = false" :open="mobileMenuOpen">
          <div class="fixed inset-0 z-10" />
          <DialogPanel
            class="fixed inset-y-0 right-0 z-10 w-full overflow-y-auto bg-indigo-950 px-6 py-6 sm:max-w-sm sm:ring-1 sm:ring-gray-900/10"
          >
            <div class="flex items-center justify-between">
              <RouterLink
                :to="{ name: 'home' }"
                @click="mobileMenuOpen = false"
                class="-m-1.5 p-1.5 font-bold text-white"
              >
                Form<span class="text-indigo-400">Thing</span>
              </RouterLink>
              <button
                type="button"
                class="-m-2.5 rounded-md p-2.5 text-white"
                @click="mobileMenuOpen = false"
              >
                <span class="sr-only">Close menu</span>
                <XMarkIcon class="h-6 w-6" aria-hidden="true" />
              </button>
            </div>
            <div class="mt-6 flow-root">
              <div class="-my-6 divide-y divide-indigo-900">
                <div class="space-y-2 py-6">
                  <RouterLink
                    v-for="item in navigation"
                    :key="item.name"
                    :to="item.to"
                    @click="mobileMenuOpen = false"
                    :class="[
                      router.currentRoute.value.name == item.to.name
                        ? 'text-white underline underline-offset-8'
                        : 'text-gray-400 hover:text-white hover:underline hover:underline-offset-8',
                      'group flex gap-2 rounded-md py-4 text-sm font-medium transition-all'
                    ]"
                    :aria-current="
                      router.currentRoute.value.name == item.to.name ? 'page' : undefined
                    "
                  >
                    <component
                      v-if="item.icon"
                      :is="item.icon"
                      class="h-5 w-5 flex-none"
                      aria-hidden="true"
                    />
                    {{ item.name }}</RouterLink
                  >
                </div>
                <div class="py-6">
                  <button
                    v-if="!authStore.actor"
                    @click="login"
                    class="px-3 py-2 text-sm font-semibold leading-6 text-white"
                  >
                    Log in <span aria-hidden="true">&rarr;</span>
                  </button>
                  <template v-if="authStore.principal">
                    <button
                      @click="copy(authStore.principal.toString(), $event)"
                      type="button"
                      class="group flex gap-2 text-left text-white"
                    >
                      <DocumentDuplicateIcon v-if="!copied" class="h-6 w-6" />
                      <CheckIcon v-else class="h-6 w-6 text-green-500" />
                      <span class="text-xs">{{ authStore.principal?.toString() }}</span>
                    </button>
                    <button
                      @click="logout"
                      class="mt-4 px-3 py-4 text-sm font-semibold leading-6 text-white"
                    >
                      Log out <span aria-hidden="true">&rarr;</span>
                    </button>
                  </template>
                </div>
              </div>
            </div>
          </DialogPanel>
        </Dialog>
      </div>
    </nav>
  </header>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { Popover, PopoverButton, PopoverPanel, DialogPanel, Dialog } from '@headlessui/vue'
import { ChevronDownIcon, PlusIcon } from '@heroicons/vue/20/solid'
import { DocumentDuplicateIcon, CheckIcon, XMarkIcon, Bars3Icon } from '@heroicons/vue/24/outline'
import { useAuthStore } from '@/stores/authStore'
import { useNotificationStore } from '@/stores/useNotificationStore'
import { useRouter } from 'vue-router'

const router = useRouter()
const authStore = useAuthStore()
const notificationStore = useNotificationStore()

const navigation = [
  {
    name: 'Forms',
    to: { name: 'admin' },
    icon: null
  },
  {
    name: 'Create Form',
    to: { name: 'adminFormCreate' },
    icon: PlusIcon
  }
]

const mobileMenuOpen = ref(false)

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
  mobileMenuOpen.value = false
}

const logout = async (e: Event) => {
  e.preventDefault()
  try {
    await authStore.logout()
    // add notification to the user
    notificationStore.addNotification({
      title: 'You have Logged Out',
      message: 'See you again soon!',
      status: 'success'
    })
    // redirect home
    router.push({ name: 'home' })
  } catch (e: any) {
    // add notification to the user
    notificationStore.addNotification({
      title: 'Logout Failed',
      message: e.message,
      status: 'error'
    })
  }
  mobileMenuOpen.value = false
}
</script>
