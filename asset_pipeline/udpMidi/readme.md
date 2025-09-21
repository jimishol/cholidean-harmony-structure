# 🎹 UDP MIDI Bridge

Streams MIDI input events over UDP in a compact **4‑byte binary format** for lightweight, low‑latency transmission.

## 📦 Installation

```bash
npm init -y
npm install easymidi
```

You’ll also need `aconnect` (part of ALSA utilities) on Linux to route MIDI devices.

## 🛠 How It Works

- Listens to a selected MIDI input port using [`easymidi`](https://www.npmjs.com/package/easymidi)  
- Encodes each event into **4 bytes**:  
  ```
  [statusByte, data1, data2, channel]
  ```
- Sends packets via UDP to `127.0.0.1:49160` by default  
- Supports `noteon`, `noteoff`, `cc` (control change), and `pitch` events

## 🎛 MIDI Routing (Linux)

Example: connect a MIDI player to the bridge, then to a synth.

```bash
# List MIDI ports
aconnect -l

# Connect player (port 14:0) to the bridge
aconnect 14:0 "midiBridgePort"

# Or connect to the fallback ALSA port
aconnect 14:0 "Midi Through:Midi Through Port-0 14:0"
```

> **Note:** The script will try to auto‑select `midiBridgePort`.  
> On Linux, if not found, it will fall back to `Midi Through:Midi Through Port-0 14:0`.

## ▶️ Usage

Run with debug logging:

```bash
node udp-midi-bridge.js --debug
```

Without debug logging:

```bash
node udp-midi-bridge.js
```

When `--debug` is enabled, MIDI events will also be printed to stdout, e.g.:

```
noteon → [90 60 100 ch0]
cc     → [b0 1 64 ch0]
```

## 🧪 Debugging with `main.lua`

A `main.lua` script is included for testing.  
It can receive and display the UDP MIDI packets sent by `udp-midi-bridge.js`.

---

### TL;DR
- Install `easymidi` and ALSA utilities  
- Connect your MIDI source to the bridge using `aconnect`  
- Run `node udp-midi-bridge.js --debug` to see events and stream them over UDP  

---

## 🚀 Prebuilt Binaries (No Node.js Required)

To make setup easier, we provide standalone binaries for:

- **Windows** (x64) — works with [loopMIDI](https://www.tobias-erichsen.de/software/loopmidi.html)  
- **macOS** (Intel & Apple Silicon) — works with the built‑in IAC Driver  
- **Linux** (x64) — works with ALSA `aconnect`

### 1. Download

Grab the latest binary for your OS from the [Releases](./releases) page.

### 2. Create a Virtual MIDI Port

- **Windows**: Create a port named `midiBridgePort` in loopMIDI  
- **macOS**: Enable the IAC Driver in Audio MIDI Setup and create a port named `midiBridgePort`  
- **Linux**: Use `aconnect` to connect your player to the bridge, or use the fallback `Midi Through:Midi Through Port-0 14:0`

### 3. Run the Bridge

```bash
# Windows
udp-midi-bridge.exe --debug

# macOS / Linux
./udp-midi-bridge --debug
```
### (Linux Only) Build Your Own Binary

If you’d rather compile the Linux executable yourself—so you don’t need Node.js on the target—run these commands in your project folder:

```bash
npm install --save-dev pkg
npm install
npx pkg . -o udp-midi-bridge
```


