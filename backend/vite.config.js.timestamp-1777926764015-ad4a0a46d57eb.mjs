// vite.config.js
import { defineConfig } from "file:///sessions/kind-tender-goodall/mnt/animal-trading-v2/backend/node_modules/vite/dist/node/index.js";
import react from "file:///sessions/kind-tender-goodall/mnt/animal-trading-v2/backend/node_modules/@vitejs/plugin-react/dist/index.js";
var vite_config_default = defineConfig({
  plugins: [react()],
  base: "/app/",
  publicDir: false,
  build: {
    outDir: "public/app",
    emptyOutDir: true
  },
  server: {
    proxy: {
      "/api": {
        target: "http://localhost:8050",
        changeOrigin: true
      }
    }
  },
  optimizeDeps: {
    include: ["leaflet", "react-leaflet"]
  }
});
export {
  vite_config_default as default
};
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsidml0ZS5jb25maWcuanMiXSwKICAic291cmNlc0NvbnRlbnQiOiBbImNvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9kaXJuYW1lID0gXCIvc2Vzc2lvbnMva2luZC10ZW5kZXItZ29vZGFsbC9tbnQvYW5pbWFsLXRyYWRpbmctdjIvYmFja2VuZFwiO2NvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9maWxlbmFtZSA9IFwiL3Nlc3Npb25zL2tpbmQtdGVuZGVyLWdvb2RhbGwvbW50L2FuaW1hbC10cmFkaW5nLXYyL2JhY2tlbmQvdml0ZS5jb25maWcuanNcIjtjb25zdCBfX3ZpdGVfaW5qZWN0ZWRfb3JpZ2luYWxfaW1wb3J0X21ldGFfdXJsID0gXCJmaWxlOi8vL3Nlc3Npb25zL2tpbmQtdGVuZGVyLWdvb2RhbGwvbW50L2FuaW1hbC10cmFkaW5nLXYyL2JhY2tlbmQvdml0ZS5jb25maWcuanNcIjtpbXBvcnQgeyBkZWZpbmVDb25maWcgfSBmcm9tICd2aXRlJztcbmltcG9ydCByZWFjdCBmcm9tICdAdml0ZWpzL3BsdWdpbi1yZWFjdCc7XG5cbmV4cG9ydCBkZWZhdWx0IGRlZmluZUNvbmZpZyh7XG4gIHBsdWdpbnM6IFtyZWFjdCgpXSxcbiAgYmFzZTogJy9hcHAvJyxcbiAgcHVibGljRGlyOiBmYWxzZSxcbiAgYnVpbGQ6IHtcbiAgICBvdXREaXI6ICdwdWJsaWMvYXBwJyxcbiAgICBlbXB0eU91dERpcjogdHJ1ZSxcbiAgfSxcbiAgc2VydmVyOiB7XG4gICAgcHJveHk6IHtcbiAgICAgICcvYXBpJzoge1xuICAgICAgICB0YXJnZXQ6ICdodHRwOi8vbG9jYWxob3N0OjgwNTAnLFxuICAgICAgICBjaGFuZ2VPcmlnaW46IHRydWUsXG4gICAgICB9LFxuICAgIH0sXG4gIH0sXG4gIG9wdGltaXplRGVwczoge1xuICAgIGluY2x1ZGU6IFsnbGVhZmxldCcsICdyZWFjdC1sZWFmbGV0J10sXG4gIH0sXG59KTtcbiJdLAogICJtYXBwaW5ncyI6ICI7QUFBbVcsU0FBUyxvQkFBb0I7QUFDaFksT0FBTyxXQUFXO0FBRWxCLElBQU8sc0JBQVEsYUFBYTtBQUFBLEVBQzFCLFNBQVMsQ0FBQyxNQUFNLENBQUM7QUFBQSxFQUNqQixNQUFNO0FBQUEsRUFDTixXQUFXO0FBQUEsRUFDWCxPQUFPO0FBQUEsSUFDTCxRQUFRO0FBQUEsSUFDUixhQUFhO0FBQUEsRUFDZjtBQUFBLEVBQ0EsUUFBUTtBQUFBLElBQ04sT0FBTztBQUFBLE1BQ0wsUUFBUTtBQUFBLFFBQ04sUUFBUTtBQUFBLFFBQ1IsY0FBYztBQUFBLE1BQ2hCO0FBQUEsSUFDRjtBQUFBLEVBQ0Y7QUFBQSxFQUNBLGNBQWM7QUFBQSxJQUNaLFNBQVMsQ0FBQyxXQUFXLGVBQWU7QUFBQSxFQUN0QztBQUNGLENBQUM7IiwKICAibmFtZXMiOiBbXQp9Cg==
