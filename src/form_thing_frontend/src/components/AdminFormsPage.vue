<template>
  <div>
    <div v-if="formStore.forms.length && !error">
      <div class="flex justify-end">
        <RouterLink
          :to="{ name: 'adminFormCreate' }"
          class="inline-flex items-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
        >
          <PlusIcon class="-ml-0.5 mr-1.5 h-5 w-5" aria-hidden="true" />
          New form
        </RouterLink>
      </div>
      <ul role="list" class="divide-y divide-gray-200">
        <li
          v-for="form in formStore.forms"
          :key="form.id"
          class="flex items-center justify-between gap-x-6 py-5"
        >
          <div class="min-w-0">
            <div class="flex items-start gap-x-3">
              <p class="text-base font-semibold leading-6 text-gray-900">{{ form.name }}</p>
              <AdminFormStatus :status="form.status" />
              <div class="flex w-16 items-center gap-x-2.5">
                <div>
                  <span class="sr-only">Total entries</span>
                  <ChatBubbleLeftIcon class="h-4 w-4 text-gray-400" aria-hidden="true" />
                </div>
                <span class="text-sm leading-6 text-gray-900">{{ form.entries_total }}</span>
              </div>
            </div>
            <div class="mt-1 flex items-center gap-x-2 text-xs leading-5 text-gray-500">
              <p class="whitespace-nowrap">
                Last updated on
                <time :datetime="formatDate(form.updated)">{{ formatDate(form.updated) }}</time>
              </p>
              <svg viewBox="0 0 2 2" class="h-0.5 w-0.5 fill-current">
                <circle cx="1" cy="1" r="1" />
              </svg>
              <p class="truncate">
                Created by
                {{
                  form.owner.toString() == authStore.principal?.toString()
                    ? 'me'
                    : `${form.owner.toString().substring(0, 3)}...${form.owner
                        .toString()
                        .substring(form.owner.toString().length - 3)}`
                }}
              </p>
            </div>
          </div>
          <div class="flex flex-none items-center gap-x-4">
            <Menu
              v-if="form.owner.toString() == authStore.principal?.toString()"
              as="div"
              class="relative flex-none"
            >
              <MenuButton class="-m-2.5 block p-2.5 text-gray-500 hover:text-gray-900">
                <span class="sr-only">Open options</span>
                <EllipsisVerticalIcon class="h-5 w-5" aria-hidden="true" />
              </MenuButton>
              <transition
                enter-active-class="transition ease-out duration-100"
                enter-from-class="transform opacity-0 scale-95"
                enter-to-class="transform opacity-100 scale-100"
                leave-active-class="transition ease-in duration-75"
                leave-from-class="transform opacity-100 scale-100"
                leave-to-class="transform opacity-0 scale-95"
              >
                <MenuItems
                  class="absolute right-0 z-10 mt-2 w-32 origin-top-right rounded-md bg-white py-2 shadow-lg ring-1 ring-gray-900/5 focus:outline-none"
                >
                  <MenuItem v-slot="{ active }">
                    <button
                      @click="updateFormSettingsModal.openModal(form as FormReturn)"
                      type="button"
                      :class="[
                        active ? 'bg-gray-50' : '',
                        'flex w-full items-center px-3 py-1 text-left text-sm leading-6 text-gray-900'
                      ]"
                    >
                      <Cog8ToothIcon class="-ml-0.5 mr-1.5 h-5 w-5" aria-hidden="true" />
                      Settings<span class="sr-only">, {{ form.name }}</span>
                    </button>
                  </MenuItem>
                  <MenuItem v-slot="{ active }">
                    <button
                      @click="formDeleteModal.openModal(form as FormReturn)"
                      type="button"
                      :class="[
                        active ? 'bg-gray-50' : '',
                        'flex w-full items-center px-3 py-1 text-sm leading-6 text-gray-900'
                      ]"
                    >
                      <ExclamationTriangleIcon class="-ml-0.5 mr-1.5 h-5 w-5" aria-hidden="true" />
                      Delete<span class="sr-only">, {{ form.name }}</span>
                    </button>
                  </MenuItem>
                </MenuItems>
              </transition>
            </Menu>
            <RouterLink
              :to="`/admin/form/${form.id}`"
              class="hidden rounded-md bg-white px-2.5 py-1.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 sm:block"
              >View form<span class="sr-only">, {{ form.name }}</span></RouterLink
            >
          </div>
        </li>
      </ul>
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
        @confirmed="formDeleteModal.onConfirmed"
      />
    </div>
    <div v-if="!formStore.forms.length && !error" class="text-center">
      <PencilSquareIcon class="mx-auto h-12 w-12 text-gray-400" aria-hidden="true" />
      <h3 class="mt-2 text-sm font-semibold text-gray-900">No forms</h3>
      <p class="mt-1 text-sm text-gray-500">Get started by creating a new form.</p>
      <div class="mt-6">
        <RouterLink
          :to="{ name: 'adminFormCreate' }"
          class="inline-flex items-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
        >
          <PlusIcon class="-ml-0.5 mr-1.5 h-5 w-5" aria-hidden="true" />
          New form
        </RouterLink>
      </div>
    </div>
    <div v-if="error" class="text-center">
      <h3 class="mt-2 text-sm font-semibold text-gray-900">
        Something went wrong fetching your forms
      </h3>
      <p class="mt-1 text-sm text-gray-500">{{ error }}</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useFormStore } from '@/stores/formStore'
import { useAuthStore } from '@/stores/authStore'
import { useSeoMeta } from '@vueuse/head'
import { Menu, MenuButton, MenuItem, MenuItems } from '@headlessui/vue'
import { EllipsisVerticalIcon, ChatBubbleLeftIcon, PlusIcon } from '@heroicons/vue/20/solid'
import { PencilSquareIcon, Cog8ToothIcon, ExclamationTriangleIcon } from '@heroicons/vue/24/outline'
import { useGeneralUtils } from '@/composables/useGeneralUtils'
import { RouterLink } from 'vue-router'
import type { FormReturn } from '@root/declarations/form_thing_backend/form_thing_backend.did.d.ts'
import { useUpdateFormSettingsModal } from '@/composables/useUpdateFormSettingsModal'
import { useFormDeleteModal } from '@/composables/useFormDeleteModal'
import { ref } from 'vue'

const authStore = useAuthStore()
const formStore = useFormStore()
const { formatDate } = useGeneralUtils()

// try to fetch forms
const error = ref<string | null>(null)
try {
  // if no forms, fetch them
  if (!formStore.forms.length) {
    await formStore.fetchFormsByUser()
  } else {
    // fetch in background to update
    formStore.fetchFormsByUser()
  }
} catch (e: any) {
  error.value = e.message
}

// Modal setup
const updateFormSettingsModal = useUpdateFormSettingsModal()
const formDeleteModal = useFormDeleteModal()

/*
 * SEO
 */
useSeoMeta({
  title: 'All Forms'
})
</script>
