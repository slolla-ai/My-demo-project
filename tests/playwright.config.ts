/**
 * Playwright configuration for px-web-app — Smart Geofence Alert Health Report tests.
 *
 * Environment variables:
 *   E2E_BASE_URL         — app base URL          (default: http://localhost:4200)
 *   E2E_ADMIN_EMAIL      — Manager/Admin user email (has report view permission)
 *   E2E_ADMIN_PASSWORD   — Manager/Admin user password
 *   E2E_NOPERMS_EMAIL    — user WITHOUT report view permission (FS-2006)
 *   E2E_NOPERMS_PASSWORD — that user's password
 */

import { defineConfig, devices } from '@playwright/test';
import path from 'path';
import dotenv from 'dotenv';

dotenv.config({ path: path.resolve(__dirname, '.env') });

const BASE_URL = process.env['E2E_BASE_URL'] ?? 'http://localhost:4200';

export default defineConfig({
  testDir: '.',
  fullyParallel: true,
  forbidOnly: !!process.env['CI'],
  retries: process.env['CI'] ? 2 : 0,
  workers: process.env['CI'] ? 4 : undefined,
  timeout: 45_000,
  expect: { timeout: 10_000 },

  reporter: [
    ['html', { outputFolder: 'playwright-report', open: 'never' }],
    ['junit', { outputFile: 'test-results/junit.xml' }],
    ['list'],
  ],

  use: {
    baseURL: BASE_URL,
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'on-first-retry',
  },

  projects: [
    // ── Auth setup — runs before all regression tests ─────────────────────
    {
      name: 'setup',
      testMatch: /auth\.setup\.ts/,
    },

    // ── Regression — full suite ────────────────────────────────────────────
    {
      name: 'regression-chromium',
      testMatch: /regression\/.*\.spec\.ts/,
      use: { ...devices['Desktop Chrome'] },
      dependencies: ['setup'],
    },
    {
      name: 'regression-firefox',
      testMatch: /regression\/.*\.spec\.ts/,
      use: { ...devices['Desktop Firefox'] },
      dependencies: ['setup'],
    },
  ],

  outputDir: 'test-results',

  webServer: process.env['CI']
    ? undefined // CI starts the app externally
    : {
        command: 'ng serve',
        url: BASE_URL,
        reuseExistingServer: true,
        timeout: 120_000,
      },
});
