© 2024–2025 Δημήτριος Χωλίδης

<div align="center">

# Cholidean Harmony Structure

</div>

  <img src="https://github.com/jimishol/jimishol.github.io/blob/main/tonality/cholidean_structure.png" alt="Theme Image" width="100%" />

Quick start examples |[MIDIport ▶](https://jimishol.github.io/tonality/cholidean-harmony-midiport.webm)  |
[FluidSynth ▶](https://jimishol.github.io/tonality/cholidean-harmony-structure.webm)  | 
[Windows ▶](https://jimishol.github.io/tonality/cholidean-harmony-windows.webm)

![The Cholidean harmonic structure operates in parallel with MuseScore, unveiling the harmony within the composition.](https://jimishol.github.io/tonality/cholidean-harmony-musescore.gif)

*The Cholidean harmonic structure operates in parallel with MuseScore, unveiling the harmony within the composition.*

Cholidean Harmony Structure is a projection of 12-tone Equal Temperament ([12ET](https://en.wikipedia.org/wiki/12_equal_temperament)) music systems into 3D space. The twelve tones are placed on a 3D parametric closed curve. The fact that each tone is related to two and only two other tones, creates strongly the perception of a two-dimensional surface strip that curves in three-dimensional space to fit the surface of an [umbilic torus](https://en.wikipedia.org/wiki/Umbilic_torus).

Project's integration with [FluidSynth](https://github.com/FluidSynth/fluidsynth), as a MIDI backend player, demonstrates a powerful method for visualizing and exploring harmony theories.

*At its heart, this project offers full 3D harmony exploration — a feature that works on all platforms when run with the null backend (no audio), so anyone can experience the concept without setup hurdles.
*

📖 **Two ways into this world:**  
- *The Watch and the Twelve Realms* — [read the origin fable](docs/the_story.md) *(first watch story at → https://jimishol.github.io/post/circle_of_fifths)*  
- *Tonality Structure in Music* — [read the tonal structure article](https://jimishol.github.io/post/tonality/)

## Installation Prerequisites and Steps 🚀

This project embeds [3DreamEngine](https://github.com/3dreamengine/3DreamEngine) — an awesome 3D engine for [LÖVE](https://love2d.org/) — directly in its codebase. Users only need to install LÖVE to run the project; no separate installation of 3DreamEngine is required.

---

### 🐧 Linux

If you’re on Linux and don’t have LÖVE installed:
```
sudo zypper install love
```
`midiport` backend needs `alsa-devel`:
```
sudo zypper install alsa-devel
```

Running, from project's ROOT directory, is simple:
```
love .
```
or
```
./run.sh
```
 this way enables the restart capability.

To enable MIDI playback with the fluidsynth backend, install fluidsynth via your package manager.
```
sudo zypper install fluidsynth
```
Then download some nice SoundFont like `FluidR3_GM.sf2`:

If your repository includes them, install
```
sudo zypper install fluid-soundfont-gm
```

> Alternatively, download the raw file from [FluidR3_GM.sf2](https://github.com/Jacalz/fluid-soundfont/blob/master/original-files/FluidR3_GM.sf2) and place it in the project’s root directory.  
> For a cleaner setup, put it in the `soundfonts/` folder and set:
> ```lua
> M.soundfonts = "soundfonts/FluidR3_GM.sf2"
> ```
> If no valid SoundFont is found, the Fluidsynth backend will fall back to its configured default (if available); otherwise, no sound will be produced.

---

### 🍎 macOS (Untested)

LÖVE and FluidSynth are available via Homebrew:

```bash
brew install love  
brew install fluidsynth
brew install coreutils
```

You can try running the project with:

love .

**Notes:**
- On macOS, `midiport` is supported. The `midiport` backend depends on ALSA and is Linux‑only.  
- The Fluidsynth backend requires `gstdbuf` (from GNU coreutils) to ensure real‑time note events are flushed immediately. Without it, you may experience delayed or batched note updates. `coreutils` provides `gstdbuf` for line‑buffered output.
- FluidSynth requires a SoundFont to produce sound.

    On some Linux distributions, a default GM SoundFont is installed automatically with FluidSynth, so you don’t need to provide one.

    On macOS (and some Linux setups), no default SoundFont is bundled. If no system‑wide default SoundFont is available, place at least one .sf2 file inside the project (root or soundfonts/ is recommended). For files outside the root, add their relative path in src/constants.lua so the fluidsynth backend can find them.
    
- CoreAudio is used automatically by FluidSynth for audio output, so no extra drivers are needed.  

macOS support has not been verified. Contributions or feedback from macOS users—especially developers—are warmly welcomed to help improve compatibility and ease of use.

---

### 🪟 Windows

✅ On Windows, the recommended backend is **`udpMidi`**, which can provide both the full 3D harmonic visualisation **and** audio/MIDI I/O — provided you have:  
- A MIDI player  
- [loopMIDI](https://www.tobias-erichsen.de/software/loopmidi.html) (or equivalent virtual MIDI cable)  
- A synth engine installed  

**loopMIDI setup:** Create a virtual MIDI port named **`midiBridgePort`** (exact spelling) and route your MIDI player’s output to it. The udpMidi bridge will automatically connect to this port.

To use udpMidi:  
1. Set `M.backend = "udpMidi"` in `src/constants.lua`.  
2. Launch the bridge binary:  
   ```
   src/backends/udpMidi/binaries/udp-midi-bridge-windows.exe
   ```

If you prefer a no‑audio mode, you can still set `M.backend = "null"`.

---

1. **Prepare the Project Directory**  
   Clone the repo (including `asset_pipeline/` and `docs/ldoc/`), or download and unzip the release ZIP.

2. **Install LÖVE**  
   Install LÖVE for Windows from the official site: https://love2d.org/  
   Use the installer so LÖVE is added to your system PATH.

3. **Launch the Visualiser**  
   From the command line:
   ```bash
   love .
   ```

---

**Known Issues:**

- **Line‑buffered output isn’t working**:  
  FluidSynth’s note‑on/off events arrive in batches under Windows; see [issue #4](https://github.com/jimishol/cholidean-harmony-structure/issues/4). Fir this, instead of `fluidsynth`, use `udpMidi` backend.

- **Spaces in filenames**:  
  May break playback through the `winpty` layer — use underscores instead.

- **Restart‑on‑exit disabled**:  
  The batch wrapper doesn’t propagate non‑zero exit codes, so automatic restart on exit code 42 is unavailable.

---

### Prerequisites

If you haven’t already installed the project via Releases, this project uses Git Large File Storage (LFS) to manage assets (mainly normal maps). Before you clone, build, or contribute, make sure Git LFS is installed and initialized:

```bash
# Install Git LFS (once per machine):

# macOS (Homebrew)
brew install git-lfs

# Windows (Chocolatey)
choco install git-lfs

# Debian/Ubuntu
sudo apt-get install git-lfs

# Initialize Git LFS
git lfs install
```
---

## 🚀 Basic Usage & Developer Integration
### 🎧 For Regular Users

This project works like a minimalist music player — but with a twist. Instead of just playing sound, it visually projects musical harmony into a 3D space, offering a unique and immersive way to experience music. The active joints (notes) become self-illuminating and grow in size. Of these, the bass notes strive valiantly to stand out with distinctive dots. The outgoing edges emit light discreetly to activate their destination. Spectral surfaces, when unambiguously indicated by active joints, materialize and emit light to attract the attention of minor or major scales that could incorporate them. The compositions are visualized in an anticipated dance of surprising steps.

- **Supported Format:** Currently supports MIDI files via FluidSynth or via the Linux ALSA midiport backend—both emit real-time note ON/OFF events for 3D visualization. On Windows, use the `udpMidi` backend for full audio‑visual output, or the `null` backend for visualization only (without audio).

- **Interactive Controls:** Users can pause playback or adjust tempo via TCP commands, making it ideal for music students or harmony learners.
- **No Technical Setup Required:** Just launch the app, load a MIDI file, and enjoy the visual harmony.

📝 Note: Future versions may support additional formats, depending on backend contributions.

---

### 🛠️ For Backend Developers

The project is designed to be extensible. Developers can integrate alternative backends as long as they can emit note ON/OFF events in real time. The backend manager is `src/backends/init.lua`.

#### 🔄 How It Works

- The core visual engine listens on the `active_notes` Love2D thread channel for updated note lists.  
- Backend threads (FluidSynth, midiport, udpMidi) push active‑note tables directly into that channel in real time.  
- The null backend falls back to disk I/O, reading from `active_notes.lua` when no channel updates occur.

#### 🧪 Backend Options

* **udpMidi (Cross‑platform)**  
  - Streams MIDI input events over UDP from a small Node.js bridge binary.  
  - On Windows, works with [loopMIDI](https://www.tobias-erichsen.de/software/loopmidi.html) or another virtual MIDI cable.  
  - **Windows setup:** Create a virtual MIDI port named `midiBridgePort` (exact spelling) and route your MIDI player’s output to it. Launch `src/backends/udpMidi/binaries/udp-midi-bridge-windows.exe`.  
  - On Linux/macOS, can connect to any ALSA/CoreMIDI port.  
  - See [`src/backends/udpMidi/readme.md`](src/backends/udpMidi/readme.md) for full setup instructions.

* **FluidSynth**  
  - Launched as a thread by the project.  
  - Outputs note events via terminal stdout.  
  - Accepts playback commands via TCP.  
  - A watcher thread connects via TCP and sends commands (e.g., play, pause, tempo).  
  - Parses FluidSynth’s noteon/noteoff output and publishes the current active‑notes list on a Love2D thread channel (`active_notes`), eliminating any file I/O for note state.

* **Null Backend (Manual Mode)**  
  - Teachers or developers can manually edit `active_notes.lua` to simulate note activity.  
  - Useful for demonstrations, teaching, or testing without a live music source.  
  - Recommended for exploring harmony in 3D space without audio.

* **midiport (Linux only)**  
  - Sniffs an ALSA MIDI port directly via FFI (default `Midi Through 14:0`).  
  - Merges and publishes active notes at ~50 Hz to `active_notes.lua`.  
  - Sends control commands (`gain`, `player_start`, etc.) over a persistent non‑blocking TCP socket, bypassing stdout buffering.  
  - Does **not** support autoplayback of MIDI files (unlike the FluidSynth backend), but offers ~80 ms faster note tracking on average.  
  - Configure in `src/constants.lua`:
    ```lua
    M.backend            = "midiport"
    M.DEFAULT_MIDI_PORT  = "14:0"
    M.shellHost          = "localhost"
    M.shellPort          = 9800
    ```

**💡 Tip — Clearing lingering notes (midiport / udpMidi)**  
With the `midiport`or udpMidi backends, if you suddenly change songs, any notes still active from the previous song will keep their status until cleared. Restart the current song (Backtab) or move to the next song (Enter) to reset the list.

**💡 Tip — Using midiport.sh to wire up your MIDI chain (midiport only)**  
The `midiport.sh` script isn’t part of this project — it’s a standalone helper that launches whichever synth engine you specify (via `SYNTH_CMD`) and wires your MIDI player → ALSA MIDI port → synth engine.

_For a deep dive into the asset pipeline, see [FOR_DEVELOPERS](asset_pipeline/FOR_DEVELOPERS.md)._

---

## 📦 Example Usage Scenarios

### 🎼 1. MIDI Playback Mode

Launch the visualizer with FluidSynth to render harmony in 3D space using real-time MIDI input.

**Linux:**
```bash
./run.sh
```

**Windows:**
```bat
love .
```
FluidSynth playback will follow whatever exists in `midi_files/` folder.

* **Camera Position Setup:**

Most likely, when examining the structure, you will find some position more suitable than others in terms of understanding it. Press `d` and copy the camera position to the `M.initialCameraPosition` field in `src/constants.lua`, so that you always start from that position. If you have preferred lightning, copy `24h Day time` to the `M.day_night` field of the same file.

* **Tonic Repositioning:**

Quite often, you will feel that the scale of a piece is such that you would like its tonic to be in a different position than it is. With `Shift + ←` or `Shift + →`, you can move the tonic to the position you desire.

---

### 🎹 2. Live MIDI Input with Fluidsynth Backend

Even when the playlist is empty or playback has ended, the Fluidsynth backend remains active and can receive live MIDI input from a connected device.

#### 🧩 Why Use This Mode?

- Ideal for **teachers** demonstrating chords, scales, or harmonic concepts live.
- Enables **interactive performances** without relying on preloaded MIDI files.
- Keeps the system responsive and visual even after automated playback ends.

#### 🔌 Connect Your MIDI Device (Linux)

Use `aconnect` to route your USB MIDI device to the Fluidsynth backend.

1. **List available MIDI ports:**

```bash
aconnect -l
```

Example output:

```
client 24: 'USB Midi' [type=kernel]
    0 'USB Midi MIDI 1 '
client 128: 'FLUID Synth' [type=user]
    0 'FLUID Synth MIDI Input'
```

2. **Connect your device to Fluidsynth:**

```bash
aconnect 24:0 128:0
```

Replace `24:0` and `128:0` with the actual port numbers from your system.

#### 🧠 What Happens Next?

- Notes played on the MIDI device are routed directly to Fluidsynth.
- The backend thread listens for `noteon` and `noteoff` events.
- `active_notes.lua` is updated in real time, allowing the main thread to visualize the notes.

💡 For lower latency (~80ms faster), the `midiport` backend offers direct ALSA access and `udpMidi` backend midi port access , though they do not support autoplayback.

#### 🔄 Tip: Use This as a Fallback

If the playlist is empty or has finished playing, this setup allows users to continue interacting with the system using a physical MIDI device — no need to restart or reconfigure the backend.

---

### 🎷 3. Live MIDI Sniffing (`midiport` / `udpMidi`)

Both the **midiport** (Linux) and **udpMidi** (cross‑platform) backends operate independently of any playback or synth engine, continuously monitoring and visualising connected MIDI devices in real time.

---

#### 📌 Setup — Linux (ALSA `midiport`)

1. **List your ALSA ports**  
   ```bash
   aconnect -l
   ```
2. **Configure the `midiport` backend** in `src/constants.lua`  
   ```lua
   -- src/constants.lua
   M.backend    = "midiport"     -- select the ALSA‐sniffing backend
   M.midiport   = "14:0"         -- ALSA client:port to sniff
   M.shellHost  = "localhost"    -- TCP host for control commands
   M.shellPort  = 9800           -- TCP port for control commands
   ```
3. **Route your MIDI device** (if needed)  
   ```bash
   aconnect 24:0 14:0
   ```
4. **Launch the visualiser**  
   ```bash
   love .
   ```

---

#### 📌 Setup — Windows / macOS / Linux (`udpMidi`)

1. **Prepare a MIDI input port**  
   - On Windows, create a virtual MIDI port named **`midiBridgePort`** in [loopMIDI](https://www.tobias-erichsen.de/software/loopmidi.html) and route your MIDI player’s output to it.  
   - On macOS/Linux, use any available CoreMIDI/ALSA port.

2. **Configure the `udpMidi` backend** in `src/constants.lua`  
   ```lua
   -- src/constants.lua
   M.backend = "udpMidi"
   ```

3. **Launch the bridge binary**  
   - **Windows**  
     ```powershell
     udp-midi-bridge-windows.exe [HOST]
     ```
   - **macOS/Linux**  
     Run the Node.js bridge script or the platform‑specific binary, optionally passing a target host.

   > 💡 **Tip:** You can pass a `[HOST]` argument to send UDP events to a specific machine.  
   > By default the bridge targets `127.0.0.1` (localhost).  
   > In classroom setups, the teacher runs the bridge on the desktop and students set the teacher’s IP in `constants.lua`.  
   > Running the **audio engine** and the **bridge binary** on separate machines can reduce CPU load and often improves both sound quality and latency.

4. **Launch the visualiser**  
   ```bash
   love .
   ```

---

#### 🎶 What Happens

- Notes from your MIDI device (USB keyboard, virtual port, or player output) are captured in real time.  
- The backend merges them into the `active_notes` Love2D thread channel (no file I/O delays).  
- The visualiser immediately reflects live playing.  
- Control commands (`gain`, `player_start`, etc.) flow over TCP exactly like in FluidSynth mode — no stdout buffering issues.

#### 🏫 Classroom Scenario — Teacher & Students

This setup can also be used in a distributed classroom environment:

- **Teacher Desktop**
  - Runs the analyzer and the UDP bridge.
  - Plays the audio locally (optionally with FluidSynth).
  - Shares its LAN IP address with students.

- **Student Laptops**
  - Run the visualiser with `M.shellHost` (in `constants.lua`) set to the teacher’s IP.
  - Receive the same UDP MIDI events over the network.
  - Display identical harmony/visuals in sync with the teacher’s audio.

**Benefits**
- One teacher machine drives many student laptops.
- Students see the same harmonic analysis in real time.
- Student laptops remain lightweight (no audio synthesis required).
- Perfect for group lessons, workshops, or demonstrations.

---

## 🎮 Keybindings & Controls

These keybindings fall into two categories:

- Playback and command-menu commands sent over TCP to the active backend (Fluidsynth by default).
- Local controls handled entirely by the visualizer core.

Only the h, d, and Ctrl + Q keys are consumed by the visualizer itself. All other bindings below are relayed as TCP messages when using a backend that accepts them (Fluidsynth by default). Future backends can repurpose or extend these.

| Key     | Function                                 |
|---------|-------------------------------------------|
| p       | Toggle play / pause                       |
| tab     | Play current song from start              |
| Enter   | Move to next song                         |
| h       | Toggle “instant” vs “offset” note-off mode|
| d       | Toggle debug overlay (FPS, camera info, note OFF mode)   |
| Ctrl + Q       | Quit                       |

### Command-Menu Controls

| Key | Function                                                                                                                         |
|-----|----------------------------------------------------------------------------------------------------------------------------------|
| :   | Open the command menu                                                                                                            |
| a   | Set tempo in BPM                                                                                                                 |
| b   | Set relative speed (e.g. `0.5` = half speed)                                                                                     |
| c   | Play the file once, then loop it `<count>` more times (`0` = cancel loop; `-1` = infinite)                                       |
| d   | Seek to an absolute tick in the current MIDI file (1 quarter-note @ 100 BPM = 600 ticks)                                         |
| e   | Raw mode: send any command string directly to the backend’s TCP server                                                          |
| h   | Help: show a scrollable list of all supported commands provided by the backend                                 |

---

## 📖 Documentation

- [Feature Overview & Configuration](docs/FEATURES_AND_CONFIG.md)  
- [Full Keybindings Reference](docs/KEYBINDINGS.md)  
- [For Developers - A.I generated ldoc documentation](https://jimishol.github.io/ldoc/)

---

## 🔄 Fluidsynth Backend Integration

The Fluidsynth backend is launched as a separate thread and communicates with the main visualizer via shared Lua channels. It handles MIDI playback and tracks active notes in real time.

### 🧠 How It Works

- A thread spawns the Fluidsynth process using platform-specific commands.
- Fluidsynth outputs `noteon` and `noteoff` events to its terminal (`stdout`).
- The thread reads these events line-by-line and maintains a table of currently active notes.

### 📁 Output Format

The `active_notes.lua` file now serves two purposes:

1. **Null backend**  
   You hand-edit this file to define which notes are “on.”  
2. **midiport backend**  
   On startup it’s cleared, then on each sniff cycle your live ALSA notes are merged _with_ whatever you’ve hand-defined here before being pushed over the channel.  

The FluidSynth backend does _not_ read or write this file — it pushes note lists entirely in memory via Love2D channels.

#### Example `active_notes.lua`
```
-- Active MIDI notes (manual/merged)
return {
    60, 64, 67,  -- C major triad
}
```

### ⚙️ Configuration Channels

| Channel Name    | Purpose                                                      |
|-----------------|--------------------------------------------------------------|
| backend         | Backend identifier (`"fluidsynth"`, `"midiport"`, `udpMidi` or `"null"`) |
| soundfonts      | Path or comma-separated list of SoundFont files              |
| songs           | Comma-separated list of MIDI files to play                   |
| shellHost       | TCP host for backend control commands                        |
| shellPort       | TCP port for backend control commands                        |
| platform        | OS identifier (`"linux"`, `"windows"`, etc.)                 |
| track_control   | Signal the FluidSynth tracker to clear its active notes      |
| quit            | Signal the midiport sniffing thread to exit                  |
| midiPort        | ALSA client:port string for the midiport backend (e.g. `"14:0"`) |
| active_notes    | Table of currently active MIDI note keys                     |

### 🧪 Notes on Stability

This system depends on:
- FluidSynth emitting clean, parseable output
- Channels being correctly populated before launch
- The subprocess staying alive and responsive

If any part fails (e.g. malformed output, missing soundfont, broken pipe), the tracker may silently stop updating. For this reason, a fallback mode (`null` backend) is available for manual control.

---

## 💬 Community & Discussions

Your feedback drives this project! Join one of our GitHub Discussions below:

- 💭 [Project's Usage & Feedback](https://github.com/jimishol/cholidean-harmony-structure/discussions/categories/project-s-usage-feedback) – share your experiences and questions about the project itself. 
- 🎼 [Interpretation of structure](https://github.com/jimishol/cholidean-harmony-structure/discussions/categories/interpretation-of-structure) – Share ideas on different interpretations of the structure’s elements.

---

## License 📝

This project is licensed under the **GNU General Public License v3.0**.  
You can find the full license text in the [LICENSE](LICENSE) file.

---

## Third-Party Licenses 📦

This project includes third-party assets that are distributed under their respective license terms.  
Please refer to the individual files in the `THIRD_PARTY_LICENSES/` directory for full details:

| Asset Type                  | License File |
|----------------------------|--------------|
| 3D Engine components        | [3dreamengine.md](THIRD_PARTY_LICENSES/3dreamengine.md) |
| Material textures & HDRIs  | [materials.md](THIRD_PARTY_LICENSES/materials.md) |
| MIDI files                  | [midis.md](THIRD_PARTY_LICENSES/midis.md) |
| Node.js runtime             | [Node.js.md](THIRD_PARTY_LICENSES/Node.js.md) |
| Third‑Party Licenses for udpMidi Binaries | [udpMidi_binaries_THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES/udpMidi_binaries_THIRD_PARTY_LICENSES.md) |

---

## Acknowledgments 🙏

This project took shape thanks to the insight and encouragement of [**Edgar Delgado Vega**](https://github.com/edelveart).

Although the idea had been explored by 20th-century music–math theorists, it was only when E.D.V. encountered the concept that he immediately recognized its potential for new approaches in 12ET harmony. He urged me to share it more widely and encouraged me to bring it into academic and creative circles. 

That encouragement transformed a dormant idea into a living project. From OpenSCAD to MeshLab, to Blender, to 3DreamEngine, to MIDI events, each stage brought new challenges and discoveries. Without Edgar Delgado’s vision and determination, this journey might never have begun.

*The revolutionary idea of such a clear projection of 12‑ET into three‑dimensional space is entirely my own. Yet the code and documentation were realised with the assistance of AI — specifically Microsoft Copilot — guided through exhaustive patience and persistence on my part. Without the help of this tool, it would have been impossible for me to bring a project of this scale to life.*
