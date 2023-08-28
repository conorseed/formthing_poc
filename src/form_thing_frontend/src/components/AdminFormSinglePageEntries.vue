<template>
  <section>
    <h2
      class="mb-6 flex flex-wrap items-end justify-between gap-2 text-2xl font-bold tracking-tight text-gray-900"
    >
      Entries
      <div class="flex items-end gap-4">
        <span class="text-sm tracking-normal text-gray-500"
          >Total Entries: {{ props.entries_total }}</span
        >
        <button
          v-if="props.entries_total > 0"
          @click="exportEntries"
          :disabled="!entries || !entries.length"
          type="submit"
          class="rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 disabled:opacity-30"
        >
          Export to CSV
        </button>
      </div>
    </h2>
    <ul
      v-if="!entries_loading && entries && entries.length"
      role="list"
      class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3"
    >
      <li
        v-for="entry in entries"
        :key="entry.id"
        class="col-span-1 divide-y divide-gray-200 rounded-lg bg-white p-6 shadow"
      >
        <div class="flex justify-between gap-x-4 py-3 text-sm text-gray-500">
          <span>#{{ entry.id }}</span>
          <span>Created: {{ entry.created }}</span>
        </div>
        <div v-if="typeof entry.data === 'object'" class="pt-4">
          <div v-for="(value, key) in entry.data" :key="key">
            <div>{{ key }}: {{ value }}</div>
          </div>
        </div>
        <div v-else>Entry could not be decrypted</div>
      </li>
    </ul>
    <ul
      v-if="entries_loading"
      role="list"
      class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3"
    >
      <li class="col-span-1 divide-y divide-gray-200 rounded-lg bg-white p-6 shadow">
        <div class="mb-4 h-2.5 animate-pulse rounded-full bg-gray-400"></div>
        <div class="pt-4">
          <div class="mb-2.5 h-2 w-40 animate-pulse rounded-full bg-gray-400"></div>
          <div class="mb-2.5 h-2 w-32 animate-pulse rounded-full bg-gray-400"></div>
          <div class="mb-2.5 h-2 w-44 animate-pulse rounded-full bg-gray-400"></div>
        </div>
      </li>
      <li class="col-span-1 divide-y divide-gray-200 rounded-lg bg-white p-6 shadow">
        <div class="mb-4 h-2.5 animate-pulse rounded-full bg-gray-400"></div>
        <div class="pt-4">
          <div class="mb-2.5 h-2 w-40 animate-pulse rounded-full bg-gray-400"></div>
          <div class="mb-2.5 h-2 w-32 animate-pulse rounded-full bg-gray-400"></div>
          <div class="mb-2.5 h-2 w-44 animate-pulse rounded-full bg-gray-400"></div>
        </div>
      </li>
      <li class="col-span-1 divide-y divide-gray-200 rounded-lg bg-white p-6 shadow">
        <div class="mb-4 h-2.5 animate-pulse rounded-full bg-gray-400"></div>
        <div class="pt-4">
          <div class="mb-2.5 h-2 w-40 animate-pulse rounded-full bg-gray-400"></div>
          <div class="mb-2.5 h-2 w-32 animate-pulse rounded-full bg-gray-400"></div>
          <div class="mb-2.5 h-2 w-44 animate-pulse rounded-full bg-gray-400"></div>
        </div>
      </li>
    </ul>
    <div
      v-if="!entries_loading && (!entries || !entries.length) && !entries_error.status"
      class="text-center"
    >
      <PencilSquareIcon class="mx-auto h-12 w-12 text-gray-400" aria-hidden="true" />
      <h3 class="mt-2 text-sm font-semibold text-gray-900">No entries yet</h3>
      <p class="mt-1 text-sm text-gray-500">Share this form to get entries.</p>
      <div class="mt-6">
        <button
          @click="copyLink"
          type="button"
          class="inline-flex items-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
        >
          <DocumentDuplicateIcon v-if="!copied" class="-ml-0.5 mr-1.5 h-5 w-5" aria-hidden="true" />
          <CheckIcon v-else class="-ml-0.5 mr-1.5 h-5 w-5" aria-hidden="true" />
          Copy Link
        </button>
      </div>
    </div>
    <div v-if="entries_error.status" class="text-center">
      <h3 class="mt-2 text-sm font-semibold text-gray-900">Error fetching entries</h3>
      <p class="mt-1 text-sm text-gray-500">{{ entries_error.message }}</p>
    </div>
  </section>
</template>

<script setup lang="ts">
import { useGeneralUtils } from '@/composables/useGeneralUtils'
import { useVetkdUtils } from '@/composables/useVetkdUtils'
import type { Entry } from '@root/declarations/form_thing_backend/form_thing_backend.did'
import { onMounted, ref } from 'vue'
import { PencilSquareIcon, DocumentDuplicateIcon, CheckIcon } from '@heroicons/vue/24/outline'
import { useAuthStore } from '@/stores/authStore'

const props = defineProps({
  form_id: {
    type: String,
    required: true
  },
  entries_total: {
    type: Number,
    required: true
  }
})

const { formatDate, sanitizeHTML } = useGeneralUtils()
const vetkdUtils = useVetkdUtils()

// fetch keys
const entries_error = ref({
  status: false,
  message: ''
})
onMounted(async () => {
  if (props.entries_total > 0) {
    try {
      const keys = await vetkdUtils.fetch_vetkeys(props.form_id)
      if (!keys) {
        throw new Error('Could not fetch keys')
      }
      get_entries()
    } catch (e: any) {
      entries_error.value = {
        status: true,
        message: e.message
      }
      entries_loading.value = false
    }
  } else {
    entries_loading.value = false
  }
})

// get entries
interface EntryDecrypted {
  id: number
  created: string
  data: {
    [key: string]: any
  }
  form_id: string
}
type EntryEncrypted = Entry & {
  id: number
}
type EntriesProcessed = Array<EntryDecrypted | EntryEncrypted>

const entries = ref<EntriesProcessed>()
const entries_loading = ref(true)

async function get_entries() {
  entries_loading.value = true
  const res = await useAuthStore().actor?.get_entries(props.form_id)

  // return early if error
  if (!res || 'err' in res) {
    entries_loading.value = false
    return
  }

  // decrypt entries
  const decrypted_entries = await Promise.all(
    res.ok.map(async (entry) => {
      // return early if form is not ready
      if (vetkdUtils.key_derived.value == null) {
        return {
          id: Number(entry[0]),
          ...entry[1]
        }
      }
      const decrypted_data = await vetkdUtils.aes_decrypt({
        ciphertext_hex: entry[1].data,
        rawKey: vetkdUtils.key_derived.value
      })
      if (!decrypted_data) {
        return {
          id: Number(entry[0]),
          ...entry[1]
        }
      }
      // parse and sanitize decrypted data
      const data = JSON.parse(decrypted_data)
      const sanitizedData: {
        [key: string]: any
      } = {}
      Object.keys(data).forEach((key) => {
        sanitizedData[sanitizeHTML(key)] = sanitizeHTML(data[key])
      })

      return {
        id: Number(entry[0]),
        ...entry[1],
        created: formatDate(entry[1].created),
        data: sanitizedData
      }
    })
  )
  entries.value = decrypted_entries
  entries_loading.value = false
}

// export entries to csv
const exportEntries = async () => {
  if (!entries.value) return
  const csv = arrayToCSV(entries.value)
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.setAttribute('href', url)
  link.setAttribute('download', `form_${props.form_id}_entries.csv`)
  link.style.visibility = 'hidden'
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}

function arrayToCSV(dataArray: EntriesProcessed) {
  // Return empty string if no data provided
  if (!dataArray || dataArray.length === 0) {
    return ''
  }

  // Extract headers from keys
  const header = Object.keys(dataArray[0]) as (keyof EntryDecrypted | keyof EntryEncrypted)[]
  // Process rows
  const rows = dataArray.map((obj) =>
    header.map((key) => {
      let value = obj[key]

      // Convert BigInt to string
      if (typeof value === 'bigint' && key == 'created') {
        value = formatDate(value)
      }

      // If value is an object, stringify it
      if (typeof value === 'object' && value !== null && !Array.isArray(value)) {
        const dataObj = value as Record<string, any>
        // iterate over object and stringify each key/value pair
        value = ''
        Object.keys(dataObj).forEach((k) => {
          value += `${k}: ${dataObj[k]}\n`
        })
      }

      // If value is a string, add quotes
      if (typeof value === 'string') {
        value = `"${value.replace(/"/g, '"')}"`
      }

      return value
    })
  )

  const csvContent = header.join(',') + '\n' + rows.map((row) => row.join(',')).join('\n') // Join data with commas and newlines

  return csvContent
}

/**
 * Copy Share link
 */
const copied = ref(false)
const copyLink = (e: Event) => {
  e.preventDefault()
  copied.value = true
  navigator.clipboard.writeText(`${window.location.origin}/forms/${props.form_id}`)
  setTimeout(() => {
    copied.value = false
  }, 2000)
}
</script>
