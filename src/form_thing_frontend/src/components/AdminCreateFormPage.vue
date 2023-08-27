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
    <div class="jus mt-5 flex justify-end">
      <button
        :disabled="!canSubmit"
        type="button"
        class="inline-flex justify-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 disabled:bg-indigo-300 sm:col-start-2"
        @click="onSubmit"
      >
        Create Form
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Principal } from '@dfinity/principal'
import { XMarkIcon } from '@heroicons/vue/24/outline'
import { computed, ref } from 'vue'
import { useFormStore } from '@/stores/formStore'
import router from '@/router'

const formStore = useFormStore()

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
  if (newUser.value !== '') {
    newForm.value?.users.push(Principal.fromText(newUser.value))
    newUser.value = ''
  }
}

// remove user
const removeUser = (user: Principal) => {
  if (!newForm.value) return
  newForm.value.users = newForm.value?.users.filter((u) => u !== user)
}

// on submit empty function
const onSubmit = async () => {
  console.log('submit')
  const res = await formStore.createForm(newForm.value as Settings)
  if (res) {
    console.log('success')
    router.push({ name: 'adminFormSingle', params: { formId: res.id } })
  }
}
</script>

<style scoped></style>
