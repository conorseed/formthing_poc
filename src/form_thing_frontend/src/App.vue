<template>
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
