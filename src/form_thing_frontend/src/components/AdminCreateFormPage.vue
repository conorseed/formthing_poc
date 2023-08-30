<template>
  <div>
    <div>
      <div class="mt-8 flex flex-col flex-wrap gap-5">
        <div>
          <label for="form.name" class="mb-2 block text-sm font-medium leading-6 text-gray-900"
            >Form name</label
          >
          <input
            v-model="newForm.name"
            type="text"
            name="form.name"
            id="form.name"
            class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
            placeholder="Awesome New Form"
          />
        </div>
        <div>
          <label for="form.status" class="mb-2 block text-sm font-medium leading-6 text-gray-900"
            >Status</label
          >
          <select
            v-model="newForm.status"
            id="form.status"
            name="form.status"
            class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
          >
            <option value="active">Active</option>
            <option value="inactive">Inactive</option>
          </select>
        </div>
        <div>
          <label for="form.users" class="mb-2 block text-sm font-medium leading-6 text-gray-900"
            >Users</label
          >
          <p class="mb-4 mt-2 text-sm text-gray-500" id="email-description">
            Add users by their principal to give them access to view form settings and entries.
          </p>
          <div class="flex flex-wrap gap-2">
            <button
              v-for="user in newForm.users"
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
          <div class="mt-4 flex content-stretch items-stretch justify-stretch justify-self-stretch">
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
    <div class="jus mt-5 flex justify-end gap-2">
      <button
        :disabled="!canSubmit || submitting"
        type="button"
        class="inline-flex justify-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 disabled:bg-indigo-300 sm:col-start-2"
        @click="onSubmit"
      >
        Create Form
      </button>
      <div v-if="submitting" role="status">
        <svg
          aria-hidden="true"
          class="mr-2 inline h-8 w-8 animate-spin fill-gray-200 text-gray-300 dark:fill-indigo-600 dark:text-gray-400"
          viewBox="0 0 100 101"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            d="M100 50.5908C100 78.2051 77.6142 100.591 50 100.591C22.3858 100.591 0 78.2051 0 50.5908C0 22.9766 22.3858 0.59082 50 0.59082C77.6142 0.59082 100 22.9766 100 50.5908ZM9.08144 50.5908C9.08144 73.1895 27.4013 91.5094 50 91.5094C72.5987 91.5094 90.9186 73.1895 90.9186 50.5908C90.9186 27.9921 72.5987 9.67226 50 9.67226C27.4013 9.67226 9.08144 27.9921 9.08144 50.5908Z"
            fill="currentColor"
          />
          <path
            d="M93.9676 39.0409C96.393 38.4038 97.8624 35.9116 97.0079 33.5539C95.2932 28.8227 92.871 24.3692 89.8167 20.348C85.8452 15.1192 80.8826 10.7238 75.2124 7.41289C69.5422 4.10194 63.2754 1.94025 56.7698 1.05124C51.7666 0.367541 46.6976 0.446843 41.7345 1.27873C39.2613 1.69328 37.813 4.19778 38.4501 6.62326C39.0873 9.04874 41.5694 10.4717 44.0505 10.1071C47.8511 9.54855 51.7191 9.52689 55.5402 10.0491C60.8642 10.7766 65.9928 12.5457 70.6331 15.2552C75.2735 17.9648 79.3347 21.5619 82.5849 25.841C84.9175 28.9121 86.7997 32.2913 88.1811 35.8758C89.083 38.2158 91.5421 39.6781 93.9676 39.0409Z"
            fill="currentFill"
          />
        </svg>
        <span class="sr-only">Loading...</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Principal } from '@dfinity/principal'
import { XMarkIcon } from '@heroicons/vue/24/outline'
import { computed, ref } from 'vue'
import { useFormStore } from '@/stores/formStore'
import { useNotificationStore } from '@/stores/useNotificationStore'
import router from '@/router'
import { useSeoMeta } from '@vueuse/head'

const formStore = useFormStore()
const notificationStore = useNotificationStore()

type Settings = {
  name: string
  status: 'active' | 'inactive'
  users: Principal[]
}

// setup new settings
const newForm = ref<Settings>({
  name: '',
  status: 'active',
  users: []
})

// can submit
const canSubmit = computed(() => {
  return newForm.value?.name !== ''
})

// add new user
const newUser = ref('')
const addUser = () => {
  try {
    if (newUser.value.trim() === '') {
      throw new Error('User cannot be empty')
    }
    newForm.value?.users.push(Principal.fromText(newUser.value.trim()))
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
  newForm.value.users = newForm.value?.users.filter((u) => u !== user)
}

// on submit empty function
const submitting = ref(false)
const onSubmit = async () => {
  if (submitting.value) return
  submitting.value = true

  // add notification so user knows something is happening
  const nid = notificationStore.addNotification({
    title: 'Creating Form',
    message: 'Please wait while we create your form.',
    status: 'loading'
  })

  try {
    const res = await formStore.createForm(newForm.value as Settings)
    if (res) {
      notificationStore.updateNotification(nid, {
        title: 'Form Created',
        message: 'Your form has been created.',
        status: 'success'
      })
      router.push({ name: 'adminFormSingle', params: { formId: res.id } })
    }
  } catch (e: any) {
    notificationStore.updateNotification(nid, {
      title: 'Error Creating Form',
      message: e.message,
      status: 'error'
    })
  }

  submitting.value = false
}

/*
 * SEO
 */
useSeoMeta({
  title: 'Create Form'
})
</script>

<style scoped></style>
