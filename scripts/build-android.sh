#!/usr/bin/env bash
set -euo pipefail

# Ensure Corepack is enabled so pnpm version from package.json is used
corepack enable

# Install dependencies (CI can use --frozen-lockfile, local can omit)
pnpm install --frozen-lockfile

# Build the Angular web PWA used as the app shell
pnpm run build:frontend:pwa

# NOTE:
# This script assumes you have already created a Capacitor-based Android
# project under ./android that points its webDir to the above build output.
# See project documentation / README for the one-time setup steps:
#   - npx cap init
#   - npx cap add android
#   - npx cap sync android

# Sync latest web assets into the Android project (no-op if already synced)
if command -v npx >/dev/null 2>&1; then
  npx cap sync android || echo "cap sync android failed (ensure Capacitor + android platform are initialized)"
else
  echo "npx not found, skipping 'cap sync android'"
fi

# Build the Android release APK (requires ./android to exist and be valid)
if [ -d "android" ]; then
  cd android
  ./gradlew clean assembleRelease
  echo "APK build complete. Outputs are under app/build/outputs/apk/release/"
else
  echo "Android project directory ./android not found. Initialize Capacitor Android project first."
fi
