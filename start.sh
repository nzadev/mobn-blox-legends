#!/usr/bin/env bash
set -euo pipefail

GAME_DIR="/home/nza/.gemini/antigravity/scratch/mobn_blox_legends"
PORT=8095

if ! ss -tln | grep -q ":${PORT} "; then
  python3 -m http.server "${PORT}" --directory "${GAME_DIR}" >/dev/null 2>&1 &
  sleep 0.6
fi

echo "MOBN: Blox Legends 5v5 running at http://127.0.0.1:${PORT}"
if command -v xdg-open >/dev/null 2>&1; then
  xdg-open "http://127.0.0.1:${PORT}" >/dev/null 2>&1 || true
fi
