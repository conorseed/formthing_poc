<template>
  <TransitionRoot as="template" :show="props.open">
    <Dialog as="div" class="relative z-10" @close="emitClose">
      <TransitionChild
        as="template"
        enter="ease-out duration-300"
        enter-from="opacity-0"
        enter-to="opacity-100"
        leave="ease-in duration-200"
        leave-from="opacity-100"
        leave-to="opacity-0"
        @before-enter="resetSettingsUpdate"
      >
        <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" />
      </TransitionChild>

      <div class="fixed inset-0 z-10 overflow-y-auto">
        <div
          class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0"
        >
          <TransitionChild
            as="template"
            enter="ease-out duration-300"
            enter-from="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
            enter-to="opacity-100 translate-y-0 sm:scale-100"
            leave="ease-in duration-200"
            leave-from="opacity-100 translate-y-0 sm:scale-100"
            leave-to="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
          >
            <DialogPanel
              v-if="form"
              class="relative transform overflow-hidden rounded-lg bg-white px-4 pb-4 pt-5 text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-lg sm:p-6"
            >
              <div>
                <div class="flex items-center justify-start gap-2">
                  <div class="flex h-8 w-8 items-center justify-center rounded-full bg-indigo-100">
                    <Cog8ToothIcon class="h-6 w-6 text-indigo-600" aria-hidden="true" />
                  </div>
                  <DialogTitle as="h3" class="text-base font-semibold"
                    >Form Settings
                    <span class="text-sm text-gray-400">#{{ form.id }}</span></DialogTitle
                  >
                </div>

                <div v-if="settingsUpdate !== null" class="mt-8 flex flex-col flex-wrap gap-5">
                  <div>
                    <label
                      for="form.name"
                      class="mb-2 block text-sm font-medium leading-6 text-gray-900"
                      >Form name</label
                    >
                    <input
                      v-model="settingsUpdate.name"
                      type="text"
                      name="form.name"
                      id="form.name"
                      class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
                      placeholder="Awesome New Form"
                    />
                  </div>
                  <div>
                    <label
                      for="form.status"
                      class="mb-2 block text-sm font-medium leading-6 text-gray-900"
                      >Status</label
                    >
                    <select
                      v-model="settingsUpdate.status"
                      id="form.status"
                      name="form.status"
                      class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
                    >
                      <option value="active">Active</option>
                      <option value="inactive">Inactive</option>
                    </select>
                  </div>
                  <div>
                    <label
                      for="form.users"
                      class="mb-2 block text-sm font-medium leading-6 text-gray-900"
                      >Users</label
                    >
                    <p class="mb-4 mt-2 text-sm text-gray-500" id="email-description">
                      Add users by their principal to give them access to view form settings and
                      entries.
                    </p>
                    <div class="flex flex-wrap gap-2">
                      <button
                        v-for="user in settingsUpdate.users"
                        :key="user.toString()"
                        @click="removeUser(user as Principal)"
                        type="button"
                        class="inline-flex items-center rounded-md bg-white px-2.5 py-1.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
                        :title="user.toString()"
                      >
                        <span class="sr-only">Remove User: </span>
                        {{ user.toString().substring(0, 3) }}...{{
                          user.toString().substring(user.toString().length - 3)
                        }}
                        <XMarkIcon class="ml-2 h-6 w-6" aria-hidden="true" />
                      </button>
                    </div>
                    <div
                      class="mt-4 flex content-stretch items-stretch justify-stretch justify-self-stretch"
                    >
                      <label class="sr-only" for="user.new">Add New User</label>
                      <input
                        v-model="newUser"
                        type="text"
                        name="user.new"
                        id="user.new"
                        class="block w-full rounded-l-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
                        placeholder="Principal ID"
                      />
                      <button
                        @click="addUser"
                        type="button"
                        class="rounded-r-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 disabled:bg-indigo-300 sm:col-start-2"
                      >
                        Add
                      </button>
                    </div>
                  </div>
                </div>
              </div>
              <div class="mt-5 sm:mt-6 sm:grid sm:grid-flow-row-dense sm:grid-cols-2 sm:gap-3">
                <button
                  :disabled="!settingsUpdated"
                  type="button"
                  class="inline-flex w-full justify-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 disabled:bg-indigo-300 sm:col-start-2"
                  @click="emitUpdateSettings"
                >
                  Update Settings
                </button>
                <button
                  type="button"
                  class="mt-3 inline-flex w-full justify-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 sm:col-start-1 sm:mt-0"
                  @click="emitClose"
                  ref="cancelButtonRef"
                >
                  Cancel
                </button>
              </div>
            </DialogPanel>
          </TransitionChild>
        </div>
      </div>
    </Dialog>
  </TransitionRoot>
</template>

<script setup lang="ts">
import { useNotificationStore } from '@/stores/useNotificationStore'
import { Principal } from '@dfinity/principal'
import { Dialog, DialogPanel, DialogTitle, TransitionChild, TransitionRoot } from '@headlessui/vue'
import { Cog8ToothIcon, XMarkIcon } from '@heroicons/vue/24/outline'
import type { FormReturn } from '@root/declarations/form_thing_backend/form_thing_backend.did.d.ts'
import { computed, ref } from 'vue'

const props = defineProps<{
  open: boolean
  form?: FormReturn
}>()

const emit = defineEmits(['close', 'updateSettings'])
const notificationStore = useNotificationStore()

type Settings = {
  name: string
  status: 'active' | 'inactive'
  users: Principal[]
}

// setup new settings
const settingsUpdate = ref<Settings | null>(null)

// computed variable to check if settings have been updated
const settingsUpdated = computed(() => {
  let updated = false

  // return early if form is null
  if (!props.form) return updated

  if (settingsUpdate.value?.name != props.form.name) {
    updated = true
  }
  if (settingsUpdate.value?.status != Object.keys(props.form.status)[0]) {
    updated = true
  }
  // check if users are the same
  // will need to convert principal to string to check
  if (settingsUpdate.value?.users.length !== props.form.users.length) {
    updated = true
  } else {
    for (let i = 0; i < settingsUpdate.value.users.length; i++) {
      if (settingsUpdate.value.users[i].toString() !== props.form.users[i].toString()) {
        updated = true
      }
    }
  }

  return updated
})

// add new user
const newUser = ref('')
const addUser = () => {
  try {
    newUser.value = newUser.value.trim()
    if (newUser.value === '') {
      throw new Error('User cannot be empty')
    }
    // check if user is owner
    if (newUser.value === props.form?.owner.toString()) {
      throw new Error('Cannot add owner to user list')
    }
    // check if user is already in list
    const exists = settingsUpdate.value?.users.find((u) => u.toString() === newUser.value)
    if (exists) {
      throw new Error('Principal already added as user')
    }
    settingsUpdate.value?.users.push(Principal.fromText(newUser.value))
    newUser.value = ''
  } catch (e: any) {
    notificationStore.addNotification({
      title: 'Error Adding User',
      message: e.message,
      status: 'error'
    })
  }
}

// remove user
const removeUser = (user: Principal) => {
  if (!settingsUpdate.value) return
  settingsUpdate.value.users = settingsUpdate.value?.users.filter((u) => u !== user)
}

// emit close
const emitClose = () => {
  emit('close')
}

// emit update settings
const emitUpdateSettings = () => {
  emit('updateSettings', settingsUpdate.value)
  emit('close')
}

// reset settings update
const resetSettingsUpdate = () => {
  if (!props.form) return
  let status = Object.keys(props.form.status)[0]
  let users: Principal[] = []
  for (const user of props.form.users) {
    users.push(Principal.fromText(user.toString()))
  }
  settingsUpdate.value = {
    name: JSON.parse(JSON.stringify(props.form.name)),
    status: status === 'active' ? 'active' : 'inactive',
    users
  }
}
</script>

<style scoped></style>
