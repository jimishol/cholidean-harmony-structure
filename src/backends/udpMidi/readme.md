# 🎹 udpMidi Backend

The **udpMidi** backend streams MIDI input events over UDP to the visualiser, enabling real‑time audio/MIDI I/O on Windows, macOS, and Linux.

---

## 🪟 Windows Quick‑Start

On Windows, udpMidi is the **recommended backend** — it can provide both the full 3D harmonic visualisation **and** audio/MIDI I/O, provided you have:  
- A MIDI player  
- [loopMIDI](https://www.tobias-erichsen.de/software/loopmidi.html) (or equivalent virtual MIDI cable)  
- A synth engine installed

**loopMIDI setup:**  
Create a virtual MIDI port named **`midiBridgePort`** (exact spelling) and route your MIDI player’s output to it. The udpMidi bridge will automatically connect to this port.

**Steps:**
1. In `src/constants.lua`, set:
   ```lua
   M.backend = "udpMidi"
   ```
2. Launch the bridge binary **before** starting the visualiser:
   ```
   src/backends/udpMidi/binaries/udp-midi-bridge-windows.exe
   ```
3. Start the visualiser:
   ```bash
   love .
   ```

---

## ⚙️ How It Works

The bridge binary wraps the Node.js script `udp-midi-bridge.js`, which:
- Opens the `midiBridgePort` MIDI input
- Encodes incoming MIDI events into a compact binary format
- Sends them via UDP to the visualiser on `127.0.0.1:49160`

---

## 📝 Notes

- If `midiBridgePort` is not found, the bridge will fall back to the first available MIDI input (or `Midi Through` on Linux).
- For no‑audio mode, set `M.backend = "null"` in `src/constants.lua`.
- On Linux/macOS, udpMidi can be used with any ALSA/CoreMIDI port — see platform‑specific docs in the main README.

---
