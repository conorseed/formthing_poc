<template>
  <div>
    <div v-if="form" class="grid gap-10 lg:grid-cols-8">
      <div class="lg:col-span-2">
        <div class="mb-4 rounded-lg bg-white p-6 shadow">
          <h2 class="mb-6 text-xl font-bold tracking-tight text-gray-900">{{ form.name }}</h2>
          <p>ID: {{ form.id }}</p>
          <p>Status: {{ form.status }}</p>
          <p class="truncate">
            Created by {{ form.owner.toString() }} on: {{ formatDate(form.created) }}
          </p>
          <p>Last Updated: {{ formatDate(form.updated) }}</p>
          <p class="truncate">Users: {{ form.users }}</p>
          <p>Share: {{ `${origin}/forms/${form.id}` }}</p>
        </div>
        <div>
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
import { useRoute } from 'vue-router'
import { type FormReturn } from '@root/declarations/form_thing_backend/form_thing_backend.did'
import { ref } from 'vue'
import { DocumentDuplicateIcon, CheckIcon } from '@heroicons/vue/24/outline'

const route = useRoute()
const formStore = useFormStore()
const { formatDate } = useGeneralUtils()

const form = ref<FormReturn | undefined>(undefined)

const res = await formStore.getFormById(route.params.formId as string)
form.value = res

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
</script>
@/composables/useGeneralUtils
