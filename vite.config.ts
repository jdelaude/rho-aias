import { defineConfig } from "vite";
import { resolve } from "path";
import fs from "fs";

// This function copies the manifest to the build folder automatically
const copyManifest = () => {
  return {
    name: "copy-manifest",
    writeBundle() {
      fs.copyFileSync("public/manifest.json", "dist/manifest.json");
      // Copy icons
      // fs.copyFileSync('public/assets/icon.png', 'dist/icon.png');
    },
  };
};

export default defineConfig({
  plugins: [copyManifest()],
  build: {
    outDir: "dist",
    emptyOutDir: true,
    rollupOptions: {
      input: {
        background: resolve(__dirname, "src/background/index.ts"),
        content: resolve(__dirname, "src/content/index.ts"),
      },
      output: {
        entryFileNames: "src/[name]/index.js",
        chunkFileNames: "assets/[name].js",
        assetFileNames: "assets/[name].[ext]",
      },
    },
  },
});
