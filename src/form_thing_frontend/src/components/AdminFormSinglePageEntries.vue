<template>
  <section>
    <h2
      class="text-2xl font-bold tracking-tight text-gray-900 mb-6 flex justify-between gap-2 flex-wrap items-end"
    >
      Entries
      <span class="text-sm text-gray-500 tracking-normal"
        >Total Entries: {{ props.entries_total }}</span
      >
    </h2>
    <ul
      v-if="!entries_loading && entries && entries.length"
      role="list"
      class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3"
    >
      <li
        v-for="(entry, i) in entries"
        :key="entry.created.toString()"
        class="col-span-1 divide-y divide-gray-200 rounded-lg bg-white shadow p-6"
      >
        <div class="flex justify-between gap-x-4 py-3 text-sm text-gray-500">
          <span>#{{ i }}</span>
          <span>Created: {{ formatDate(entry.created) }}</span>
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
      <li class="col-span-1 divide-y divide-gray-200 rounded-lg bg-white shadow p-6">
        <div class="h-2.5 bg-gray-400 rounded-full mb-4 animate-pulse"></div>
        <div class="pt-4">
          <div class="h-2 bg-gray-400 rounded-full w-40 mb-2.5 animate-pulse"></div>
          <div class="h-2 bg-gray-400 rounded-full w-32 mb-2.5 animate-pulse"></div>
          <div class="h-2 bg-gray-400 rounded-full w-44 mb-2.5 animate-pulse"></div>
        </div>
      </li>
      <li class="col-span-1 divide-y divide-gray-200 rounded-lg bg-white shadow p-6">
        <div class="h-2.5 bg-gray-400 rounded-full mb-4 animate-pulse"></div>
        <div class="pt-4">
          <div class="h-2 bg-gray-400 rounded-full w-40 mb-2.5 animate-pulse"></div>
          <div class="h-2 bg-gray-400 rounded-full w-32 mb-2.5 animate-pulse"></div>
          <div class="h-2 bg-gray-400 rounded-full w-44 mb-2.5 animate-pulse"></div>
        </div>
      </li>
      <li class="col-span-1 divide-y divide-gray-200 rounded-lg bg-white shadow p-6">
        <div class="h-2.5 bg-gray-400 rounded-full mb-4 animate-pulse"></div>
        <div class="pt-4">
          <div class="h-2 bg-gray-400 rounded-full w-40 mb-2.5 animate-pulse"></div>
          <div class="h-2 bg-gray-400 rounded-full w-32 mb-2.5 animate-pulse"></div>
          <div class="h-2 bg-gray-400 rounded-full w-44 mb-2.5 animate-pulse"></div>
        </div>
      </li>
    </ul>
    <div v-if="!entries_loading && (!entries || !entries.length)" class="text-center">
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
  </section>
</template>

<script setup lang="ts">
import { useGeneralUtils } from '@/composables/useGeneralUtils'
import { useVetkdUtils } from '@/composables/useVetkdUtils'
import type { EntriesReturn } from '@root/declarations/form_thing_backend/form_thing_backend.did'
import { onMounted, ref } from 'vue'
import { PencilSquareIcon, DocumentDuplicateIcon, CheckIcon } from '@heroicons/vue/24/outline'

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

const { formatDate } = useGeneralUtils()
const vetkdUtils = useVetkdUtils()

// fetch keys
onMounted(async () => {
  if (props.entries_total > 0) {
    const keys = await vetkdUtils.fetch_vetkeys(props.form_id)
    if (!keys) {
      console.warn('fetch_vetkeys', 'no keys found')
      entries_loading.value = false
      return
    }
    get_entries()
  } else {
    entries_loading.value = false
  }
})

// get entries
interface EntryDecrypted {
  created: bigint
  data: {
    [key: string]: any
  }
  form_id: string
}
type EntriesDecrypted = Array<EntryDecrypted>

const entries = ref<EntriesDecrypted | EntriesReturn>()
const entries_loading = ref(true)

async function get_entries() {
  entries_loading.value = true
  const res = await vetkdUtils.form_thing_backend.get_entries(props.form_id)
  // return early if error
  if ('err' in res) {
    console.warn('get_entries', res.err)
    entries_loading.value = false
    return
  }

  // decrypt entries
  const decrypted_entries = await Promise.all(
    res.ok.map(async (entry) => {
      // return early if form is not ready
      if (vetkdUtils.key_derived.value == null) {
        return {
          ...entry
        }
      }
      const decrypted_data = await vetkdUtils.aes_decrypt({
        ciphertext_hex: entry.data,
        rawKey: vetkdUtils.key_derived.value
      })
      return {
        form_id: entry.form_id,
        data: JSON.parse(decrypted_data),
        created: entry.created
      }
    })
  )
  entries.value = decrypted_entries
  entries_loading.value = false
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
