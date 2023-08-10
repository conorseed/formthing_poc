import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vite'
import EnvironmentPlugin from 'vite-plugin-environment'
import wasm from 'vite-plugin-wasm'
import vue from '@vitejs/plugin-vue'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    EnvironmentPlugin('all', { prefix: 'CANISTER_' }),
    EnvironmentPlugin('all', { prefix: 'DFX_' }),
    EnvironmentPlugin({ BACKEND_CANISTER_ID: '' }),
    wasm(),
    vue()
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
  }
})
