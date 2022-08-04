import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    watch: false,
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
    include: ['**\/*.{test,spec}.{ts,tsx}'],
    exclude: ['node_modules', 'dist', '.git',]
  },
});
