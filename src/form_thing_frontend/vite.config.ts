import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vite'
import EnvironmentPlugin from 'vite-plugin-environment'
import wasm from 'vite-plugin-wasm'
import vue from '@vitejs/plugin-vue'
import Components from 'unplugin-vue-components/vite'
import { ViteImageOptimizer } from 'vite-plugin-image-optimizer'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
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
  }
})
