<template>
  <p
    :class="[
      getStatusClasses(Object.keys(status)[0]),
      'mt-0.5 whitespace-nowrap rounded-md px-1.5 py-0.5 text-xs font-medium capitalize ring-1 ring-inset'
    ]"
  >
    {{ Object.keys(status)[0] }}
  </p>
</template>

<script setup lang="ts">
import type { FormStatus } from '@root/declarations/form_thing_backend/form_thing_backend.did'

defineProps<{
  status: FormStatus
}>()

const statuses = {
  active: 'text-green-700 bg-green-50 ring-green-600/20',
  inactive: 'text-gray-600 bg-gray-50 ring-gray-500/10'
}

const getStatusClasses = (status: string) => {
  switch (status) {
    case 'active':
      return statuses.active
    case 'inactive':
      return statuses.inactive
  }
}
</script>

<style scoped></style>
