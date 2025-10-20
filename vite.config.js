import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import { svelte } from '@sveltejs/vite-plugin-svelte'
import tailwindcss from '@tailwindcss/vite'
import path from 'path'
import { fileURLToPath } from 'url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))

export default defineConfig({
  plugins: [
    RubyPlugin(),
    svelte(),
    tailwindcss()
  ],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, 'app/frontend'),
      '$lib': path.resolve(__dirname, 'app/frontend/lib')
    }
  },
  build: {
    // Generate manifest for Rails asset pipeline
    manifest: true,
    // Use Rollup for better tree-shaking
    rollupOptions: {
      output: {
        // Manual chunk splitting for better caching
        manualChunks: {
          // Separate vendor chunks for better long-term caching
          svelte: ['svelte'],
          inertia: ['@inertiajs/svelte']
        }
      }
    },
    // Target modern browsers for smaller bundle sizes
    target: 'es2020',
    // Source maps for production debugging
    sourcemap: true
  }
})
