#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[build] Building frontend (SvelteKit/Vite) -> frontend/build ..."
(cd "${ROOT_DIR}/frontend" && npm run build)

echo "[build] Building Tauri bundles ..."
cd "${ROOT_DIR}/backend"

if command -v tauri >/dev/null 2>&1; then
  tauri build "$@"
elif cargo tauri -V >/dev/null 2>&1; then
  cargo tauri build "$@"
else
  echo "[build] ERROR: No Tauri CLI found."
  echo "[build] Install one of:"
  echo "  - npm:  npm install -g \"@tauri-apps/cli@^2\""
  echo "  - cargo: cargo install tauri-cli"
  exit 1
fi

