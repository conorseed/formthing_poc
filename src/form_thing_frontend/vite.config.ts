import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vite'
import EnvironmentPlugin from 'vite-plugin-environment'
import wasm from 'vite-plugin-wasm'
import vue from '@vitejs/plugin-vue'
import Components from 'unplugin-vue-components/vite'
import { ViteImageOptimizer } from 'vite-plugin-image-optimizer'
import topLevelAwait from 'vite-plugin-top-level-await'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    topLevelAwait({
      // The export name of top-level await promise for each chunk module
      promiseExportName: '__tla',
      // The function to generate import names of top-level await promise in each chunk module
      promiseImportName: (i) => `__tla_${i}`
    }),
    EnvironmentPlugin('all', { prefix: 'CANISTER_' }),
    EnvironmentPlugin('all', { prefix: 'CANISTER_', defineOn: 'import.meta.env' }),
    EnvironmentPlugin('all', { prefix: 'DFX_' }),
    EnvironmentPlugin('all', { prefix: 'DFX_', defineOn: 'import.meta.env' }),
    wasm(),
    vue(),
    Components(),
    ViteImageOptimizer({ includePublic: true })
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
      '@root': fileURLToPath(new URL('../', import.meta.url))
    }
  },
  define: {
    global: 'window'
  },
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:4943',
        changeOrigin: true
      }
    }
  },
  build: {
    rollupOptions: {
      onwarn: ({ loc }) => {
        if (loc?.file?.match(/js-sha256\/src\/sha256.js$/)) return
      }
    }
  }
})
