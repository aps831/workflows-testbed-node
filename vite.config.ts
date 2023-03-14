/// <reference types="vitest" />

import { defineConfig } from "vite";

export default defineConfig({
    test: {
        exclude: ["**/.trunk/**", "**/node_modules/**"],
        globals: true,
        coverage: {
            provider: "c8",
            reporter: ["text", "json", "html"],
        },
    },
});
