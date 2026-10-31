import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// `npm run dev` proxies API calls to the FastAPI server on :8000.
// `npm run build` writes the production bundle into backend/frontend_dist, which FastAPI serves.
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: { '/api': 'http://127.0.0.1:8000', '/media': 'http://127.0.0.1:8000' },
  },
  build: { outDir: '../backend/frontend_dist', emptyOutDir: true },
})
