#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${1:-}" == "--web" ]]; then
    echo "[MOBN] Starting Legacy WebGL HTTP Server on http://127.0.0.1:8095 ..."
    exec python3 -m http.server 8095 --bind 127.0.0.1 --directory "$PROJECT_DIR"
elif [[ "${1:-}" == "--editor" ]]; then
    echo "[MOBN] Launching Godot 4.7 Editor..."
    exec /usr/bin/godot --editor --path "$PROJECT_DIR"
elif [[ "${1:-}" == "--test" ]]; then
    echo "[MOBN] Running Godot 4.7 Headless Verification Suite..."
    exec /usr/bin/godot --headless --path "$PROJECT_DIR" res://tests/TestRunner.tscn
else
    echo "[MOBN] Launching MOBN: Blox Legends 5v5 on Godot 4.7 Engine..."
    exec /usr/bin/godot --path "$PROJECT_DIR"
fi
