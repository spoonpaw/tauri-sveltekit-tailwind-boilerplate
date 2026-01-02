#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cleanup() {
  if [[ -n "${FRONTEND_PID:-}" ]]; then
    kill "${FRONTEND_PID}" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT INT TERM

echo "[dev] Starting frontend (SvelteKit) on http://localhost:5173 ..."
(cd "${ROOT_DIR}/frontend" && npm run dev -- --host 127.0.0.1) &
FRONTEND_PID=$!

echo "[dev] Starting Tauri ..."
cd "${ROOT_DIR}/backend"
if command -v tauri >/dev/null 2>&1; then
  tauri dev
elif cargo tauri -V >/dev/null 2>&1; then
  cargo tauri dev
else
  echo "[dev] ERROR: No Tauri CLI found."
  echo "[dev] Install one of:"
  echo "  - npm:  npm install -g \"@tauri-apps/cli@^2\""
  echo "  - cargo: cargo install tauri-cli"
  exit 1
fi

