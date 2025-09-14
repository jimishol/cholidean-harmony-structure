#!/usr/bin/env bash
# This script sets up and runs a MIDI playback chain:
#   MIDI player → ALSA MIDI port → FluidSynth synth engine.
# It handles error checking, auto-detects the synth port,
# and ensures each component launches in the correct order.

set -euo pipefail
IFS=$'\n\t'
# -e: exit on any command failure
# -u: treat unset variables as errors
# -o pipefail: fail if any part of a pipeline fails

# ── Configuration ─────────────────────────────────────────────────────────────
MIDI_PORT="14:0"                       # Your MIDI input port (hw:client:port)
SYNTH_CMD="fluidsynth -m alsa_seq -s"   # Command to start FluidSynth in ALSA MIDI mode
SYNTH_PORT=""                          # Leave empty to auto-detect below
PLAYER_DIR="$HOME/my_github"           # Directory where your MIDI player lives
PLAYER_APP="dmidiplayer-1.7.5-x86_64.AppImage"  # MIDI player executable

# ── Launch FluidSynth in Its Own Terminal ────────────────────────────────────
# We start FluidSynth in a dedicated window so it can receive signals directly.
if command -v xterm >/dev/null; then
  xterm -e bash -c "exec $SYNTH_CMD" &
elif command -v gnome-terminal >/dev/null; then
  gnome-terminal -- bash -c "exec $SYNTH_CMD" &
elif command -v konsole >/dev/null; then
  konsole -e bash -c "exec $SYNTH_CMD" &
else
  echo "⚠️  No supported terminal found; running FluidSynth in background."
  exec $SYNTH_CMD &
fi

# Give FluidSynth a moment to register with ALSA
sleep 2

# ── Auto-detect FluidSynth Port ───────────────────────────────────────────────
# If SYNTH_PORT is unset, scan aconnect output for FluidSynth's input port.
if [[ -z "$SYNTH_PORT" ]]; then
  SYNTH_PORT=$(aconnect -l \
    | awk '
        /^client [0-9]+: .*FLUID Synth/ {
          sub(/:/, "", $2); client=$2
        }
        client && /Synth input port/ {
          print client ":" $1
          exit
        }')
  # Fallback to 128:0 if detection fails
  SYNTH_PORT=${SYNTH_PORT:-"128:0"}
fi

# ── Wire Your MIDI Chain ───────────────────────────────────────────────────────
echo "Connecting $MIDI_PORT → $SYNTH_PORT"
aconnect "$MIDI_PORT" "$SYNTH_PORT"

# ── Launch Your MIDI Player ───────────────────────────────────────────────────
echo "Starting player in $PLAYER_DIR"
cd "$PLAYER_DIR"
./"$PLAYER_APP" &
