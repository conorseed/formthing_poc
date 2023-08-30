<template>
  <div class="text-bold text-red-80 bg-red-300 px-6 py-2 text-center text-sm">
    This is a demo only. Do not use this in production or for sensitive data.
    <a class="underline" target="_blank" href="https://github.com/conorseed/formthing_poc"
      >More info.</a
    >
  </div>
  <RouterView />
</template>

<script setup lang="ts">
import { useHead } from '@vueuse/head'

useHead({
  titleTemplate: (title?: string) =>
    !title ? 'Form Thing | Beautiful Encrypted Forms on the Blockchain' : `${title} | Form Thing`,
  meta: [
    {
      name: 'description',
      content:
        'FormThing: Build beautiful, accessible forms on the IC with End-to-End Encryption where it counts. Because protecting your data should be effortless.'
    }
  ]
})
</script>
