/// <reference types="vitest" />

import { defineConfig } from "vite";

export default defineConfig({
    test: {
        exclude: ["**/.trunk/**", "**/node_modules/**"],
        globals: true,
        reporters: ["default", "junit"],
        outputFile: "./outputs/unit-tests/junit.xml",
        coverage: {
            provider: "v8",
            reporter: ["text", "json", "html"],
            reportsDirectory: "./outputs/coverage",
        },
        hookTimeout: 60000,
    },
});
