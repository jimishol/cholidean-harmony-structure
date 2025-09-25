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

2. Launch the bridge binary.  
   By default it sends to `127.0.0.1`, but you can pass a target host/IP as the first argument:
   ```
   udp-midi-bridge-windows.exe [STUDENT_IP]
   ```
   - Example (single laptop):  
     ```
     udp-midi-bridge-windows.exe 192.168.0.101
     ```
   - For a classroom with multiple laptops, the teacher can run **one instance per student IP**.  
     A small script (batch/shell) can automate launching several bridge processes in the background.

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
- On Linux/macOS, udpMidi can be used with any ALSA/CoreMIDI port — see platform‑specific docs in the main README.

---
