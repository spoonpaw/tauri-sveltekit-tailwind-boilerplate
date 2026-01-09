#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[setup] Installing frontend dependencies (npm ci) ..."
cd "${ROOT_DIR}/frontend"
if [[ -f package-lock.json ]]; then
  # npm ci requires package-lock.json to match package.json exactly.
  # When deps change, fall back to npm install to refresh the lockfile.
  if ! npm ci; then
    echo "[setup] npm ci failed (lockfile likely out of sync). Falling back to npm install ..."
    npm install
  fi
else
  npm install
fi

echo ""
echo "[setup] Done."
echo "[setup] Next:"
echo "  - Dev:  ./dev.sh"
echo "  - Build: ./build.sh"


