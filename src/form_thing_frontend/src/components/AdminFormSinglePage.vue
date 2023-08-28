<template>
  <div>
    <div v-if="form" class="grid gap-10 lg:grid-cols-8">
      <div class="lg:col-span-2">
        <div class="mb-4 rounded-lg bg-white p-6 shadow">
          <div class="mb-2 flex justify-between gap-2">
            <p class="text-sm text-gray-500">#{{ form.id }}</p>
            <AdminFormStatus :status="form.status" />
          </div>
          <h2
            class="mb-6 border-b border-solid border-gray-200 pb-3 text-xl font-bold tracking-tight text-gray-900"
          >
            {{ form.name }}
          </h2>
          <p class="mb-1 mt-2 text-sm font-bold text-gray-500">Owner</p>
          <p :title="form.owner.toString()">
            {{ form.owner.toString().substring(0, 3) }}...{{
              form.owner.toString().substring(form.owner.toString().length - 3)
            }}
          </p>
          <p class="mb-1 mt-2 text-sm font-bold text-gray-500">Last Updated</p>
          <p>{{ formatDate(form.updated) }}</p>
          <p class="mb-1 mt-2 text-sm font-bold text-gray-500">Created</p>
          <p class="truncate">{{ formatDate(form.created) }}<br /></p>
          <p class="mb-1 mt-2 text-sm font-bold text-gray-500">Users</p>
          <div class="flex flex-wrap gap-2">
            <span
              v-for="user in form.users"
              :key="user.toString()"
              class="inline-flex items-center rounded-md bg-white px-2.5 py-1.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300"
              :title="user.toString()"
            >
              {{ user.toString().substring(0, 3) }}...{{
                user.toString().substring(user.toString().length - 3)
              }}
            </span>
          </div>
        </div>
        <div class="flex flex-wrap gap-2">
          <button
            v-if="form.owner.toString() == authStore.principal?.toString()"
            @click="updateFormSettingsModal.openModal(form as FormReturn)"
            type="button"
            class="inline-flex items-center rounded-md bg-white px-2.5 py-1.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
          >
            <Cog8ToothIcon class="-ml-0.5 mr-1.5 h-5 w-5" aria-hidden="true" />
            Settings
          </button>
          <button
            @click="copyLink"
            type="button"
            class="inline-flex items-center rounded-md bg-white px-2.5 py-1.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
          >
            <DocumentDuplicateIcon
              v-if="!copied"
              class="-ml-0.5 mr-1.5 h-5 w-5"
              aria-hidden="true"
            />
            <CheckIcon v-else class="-ml-0.5 mr-1.5 h-5 w-5" aria-hidden="true" />
            Copy Form Link
          </button>

          <button
            v-if="form.owner.toString() == authStore.principal?.toString()"
            @click="formDeleteModal.openModal(form as FormReturn)"
            type="button"
            class="inline-flex items-center rounded-md bg-red-100 px-2.5 py-1.5 text-sm font-semibold text-red-600 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
          >
            <ExclamationTriangleIcon class="-ml-0.5 mr-1.5 h-5 w-5" aria-hidden="true" />
            Delete Form
          </button>

          <AdminModalFormSettings
            :form="updateFormSettingsModal.currentForm.value"
            :open="updateFormSettingsModal.isOpen.value"
            @close="updateFormSettingsModal.onClose"
            @updateSettings="updateFormSettingsModal.onUpdateSettings"
          />
          <AdminModalFormDelete
            :form="formDeleteModal.currentForm.value"
            :open="formDeleteModal.isOpen.value"
            @close="formDeleteModal.onClose"
            @confirmed="formDeleteModal.onConfirmed(onConfirmedCallback)"
          />
        </div>
      </div>
      <AdminFormSinglePageEntries
        :form_id="form.id"
        :entries_total="Number(form.entries_total)"
        class="lg:col-span-6"
      />
    </div>
    <div v-else class="text-center">
      <h1 class="mt-4 text-3xl font-bold tracking-tight text-gray-900 sm:text-5xl">
        Form not found
      </h1>
      <p class="mt-6 text-base leading-7 text-gray-600">
        Sorry, either the form doesn't exist or you don't have access.
      </p>
      <div class="mt-10 flex items-center justify-center gap-x-6">
        <RouterLink
          :to="{ name: 'admin' }"
          class="rounded-md bg-indigo-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
        >
          View my forms
        </RouterLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useGeneralUtils } from '@/composables/useGeneralUtils'
import { useFormStore } from '@/stores/formStore'
import { useAuthStore } from '@/stores/authStore'
import { useRoute, useRouter } from 'vue-router'
import { type FormReturn } from '@root/declarations/form_thing_backend/form_thing_backend.did'
import { ref } from 'vue'
import {
  DocumentDuplicateIcon,
  CheckIcon,
  Cog8ToothIcon,
  ExclamationTriangleIcon
} from '@heroicons/vue/24/outline'
import { useUpdateFormSettingsModal } from '@/composables/useUpdateFormSettingsModal'
import { useFormDeleteModal } from '@/composables/useFormDeleteModal'

const router = useRouter()
const route = useRoute()
const formStore = useFormStore()
const authStore = useAuthStore()
const { formatDate } = useGeneralUtils()

// setup form
const form = ref<FormReturn | undefined>(undefined)
const res = await formStore.getFormById(route.params.formId as string)
form.value = res

if (form.value) {
  for (const user of form.value.users) {
    console.log(user.toString())
  }
}

// setup share link
const origin = window.location.origin
const copied = ref(false)
const copyLink = (e: Event) => {
  e.preventDefault()
  if (!form.value) return
  copied.value = true
  navigator.clipboard.writeText(`${origin}/forms/${form.value.id}`)
  setTimeout(() => {
    copied.value = false
  }, 2000)
}

// Modal setup
const updateFormSettingsModal = useUpdateFormSettingsModal()
const formDeleteModal = useFormDeleteModal()

// delete modal onConfirmed callback
const onConfirmedCallback = () => {
  router.push({ name: 'admin' })
}
</script>
