#!/usr/bin/env sh
# Relaunch LÖVE when the game exits with code 42.

RESTART_CODE="${RESTART_CODE:-42}"

# Ensure we run from the script's directory (project root).
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

# Check that 'love' is available.
if ! command -v love >/dev/null 2>&1; then
  echo "Error: 'love' executable not found in PATH."
  exit 127
fi

while :; do
  love --console .
  code=$?
  if [ "$code" -eq "$RESTART_CODE" ]; then
    echo "Restart requested (exit $code). Relaunching..."
    sleep 0.5
    continue
  else
    echo "Exiting (code $code)."
    exit "$code"
  fi
done
