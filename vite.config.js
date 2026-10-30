import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// Relative paths allow deployment under a GitHub Pages repository subpath.
export default defineConfig({
  plugins: [react()],
  base: './',
});
