<div align="center">

# Cholidean Harmony Structure

</div>

  <img src="https://github.com/jimishol/jimishol.github.io/blob/main/tonality/cholidean_structure.png" alt="Theme Image" width="100%" />

Cholidean Harmony Structure is a projection of 12-tone Equal Temperament ([12ET](https://en.wikipedia.org/wiki/12_equal_temperament)) music systems into 3D space. The twelve tones are placed on a 3D parametric closed curve. The fact that each tone is related to two and only two other tones, creates strongly the perception of a two-dimensional surface strip that curves in three-dimensional space to fit the surface of an [umbilic torus](https://en.wikipedia.org/wiki/Umbilic_torus).

Project's integration with [FluidSynth](https://github.com/FluidSynth/fluidsynth), as a MIDI backend player, demonstrates a powerful method for visualizing and exploring harmony theories.

📖 **Two ways into this world:**  
- *The Watch and the Twelve Realms* — [read the origin fable](docs/the_story.md) *(first watch story at → https://jimishol.github.io/post/circle_of_fifths)*  
- *Tonality Structure in Music* — [read the tonal structure article](https://jimishol.github.io/post/tonality/)

## Installation Prerequisites and Steps 🚀

This project embeds [3DreamEngine](https://github.com/3dreamengine/3DreamEngine) — an awesome 3D engine for [LÖVE](https://love2d.org/) — directly in its codebase. Users only need to install LÖVE to run the project; no separate installation of 3DreamEngine is required.

---

### 🐧 Linux

If you're on Linux and have not LÖVE installed,
```
sudo zypper install love
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

To enable MIDI playback, install FluidSynth via your package manager:
```
sudo zypper install fluidsynth
```
Then download some nice SoundFont like `FluidR3_GM.sf2`:

If your repository include them, install
```
sudo zypper install fluid-soundfont-gm
```
or take them from https://github.com/Jacalz/fluid-soundfont/blob/master/original-files/FluidR3_GM.sf2 (use “Download raw file”) and place it in project's root. There is no need to place sounfonts in project's root in that case.

---

### 🍎 macOS (Untested)

LÖVE and FluidSynth are available via Homebrew:

brew install love  
brew install fluidsynth

You can try running the project with:

love .

Note: macOS support is currently unverified. This project was built with love and determination by a non-developer, with lots of trial, error, and A.I. guidance. Contributions or feedback from macOS users—especially developers—are warmly welcomed to help improve compatibility and ease of use.

---

### 🪟 Windows

Before running the project on Windows, make sure you have a machine or VM with real GPU support, 3D acceleration, and OpenGL enabled. 

1. **Prepare the Project Directory**  
   - Clone (if you want asset_pipeline and/or docs folders aimed for developers) or Download release zip (e.g. `cholidean-harmony-structure-0.1.2-alpha.zip`).  
   - Unzip it anywhere you like, for example:  
     C:\Users\<YourUsername>\  

2. **Install LÖVE (Love2D)**  
   - Visit https://love2d.org/ and Download the Windows zip (portable version).  
   - Unzip to a folder of your choice, for example:  
     C:\Users\<YourUsername>\
   - Move all contents of LÖVE folder (after all you can recreate them from the .zip file) into Project's Directory.  
   - After this step, `main.lua`, `conf.lua`, and any other project assets should sit next to `love.exe`.

3. **Install FluidSynth**  
     Download the binaries  
      - Go to https://github.com/FluidSynth/fluidsynth/releases and grab the latest Windows zip.  
      - Unzip it into Project's Directory (same place as `main.lua`). This will create `lib\`, `include\`, and `bin\`subfolders in it.

4. **Add SoundFonts**  
   - FluidSynth doesn’t ship with a default SoundFont.  
   - Download `FluidR3_GM.sf2` from:  
     https://github.com/Jacalz/fluid-soundfont/blob/master/original-files/FluidR3_GM.sf2  
     (use “Download raw file”)  
   - Place `FluidR3_GM.sf2` in Project's Directory (next to `main.lua`).

5. **Install Git for Windows (a necessity for winpty)**  
   - Download Git for Windows from https://github.com/git-for-windows/git/releases (e.g. `v2.50.1.windows.1`). Scroll down to find assets and pick the latest installer.
    
   - Install and reboot your machine.  
  
   - Launch the game by
   
6.  **Double Click** on `run.bat` file.



**Known Issue:**

⚠️ Windows‑specific notes

* No spaces in song filenames — The current backend passes song paths directly to FluidSynth under Bash. On Windows, spaces in filenames can break playback due to how arguments are parsed through the winpty layer. Please rename files or use underscores instead. (Example: My Song.mid → My_Song.mid)

* Restart-on-exit is disabled — On Linux/macOS, exiting with code 42 will automatically restart the game. On Windows, the winpty compatibility layer does not return non‑zero exit codes to the batch wrapper, so this feature isn’t currently supported.

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

   - Supported Format: Currently supports MIDI files, thanks to FluidSynth’s ability to emit real-time note ON/OFF events.

   - Interactive Controls: Users can pause playback or slow down tempo, making it ideal for music students or harmony learners.

   - No Technical Setup Required: Just launch the app, load a MIDI file, and enjoy the visual harmony.

📝 Note: Future versions may support additional formats, depending on backend contributions.

### 🛠️ For Backend Developers

The project is designed to be extensible. Developers can integrate alternative backends as long as they can emit note ON/OFF events in real time. The backend manager is src/backends/init.lua file.

#### 🔄 How It Works

   - The core visual engine watches a file called active_notes.lua on disk.

   - This file contains a list of currently active notes, which the engine reads and renders in 3D.

   - A backend thread (e.g., FluidSynth) updates this file in real time based on backend playback.

#### 🧪 Backend Options

   * FluidSynth Backend:

      - Launched as a thread by the project.

      - Outputs note events via terminal stdout.

      - Accepts playback commands via TCP.

      - A watcher thread connects via TCP and sends commands (e.g., play, pause, tempo).

      - Updates active_notes.lua based on parsed output.

   * Null Backend (Manual Mode):

      - Teachers or developers can manually edit active_notes.lua to simulate note activity.

      - Useful for demonstrations, teaching, or testing without a live music source.

🔧 Future Improvement

   * Direct Terminal Parsing:

      - Instead of writing to disk, the watcher may read directly from FluidSynth’s terminal output.

      - This would improve performance but may remove support for manual editing.

      - Decision pending based on community interest and use cases.

For a deep dive into the asset pipeline, see [FOR_DEVELOPERS](asset_pipeline/FOR_DEVELOPERS.md).

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
Double-click run.bat
```

FluidSynth playback will follow the playlist defined in `play.list`.

* **Playlist Format:**


The `play.list` file should contain a comma-separated list of MIDI file paths:

```
assets/beethoven_symphony_5_1_(c)galimberti.mid,
assets/moonlight_sonata.mid,
assets/fur_elise.mid,
```
Each entry should be a relative or absolute path to a `.mid` file. Trailing commas are allowed but not required.

* **Camera Position Setup:**

Most likely, when examining the structure, you will find some position more suitable than others in terms of understanding it. Press `d` and copy the camera position to the `M.initialCameraPosition` field in `src/constants.lua`, so that you always start from that position. If you have prefered lightning copy `Day time` to the `M.day_night` field of the same file.

* **Tonic Repositioning:**

Quite often, you will feel that the scale of a piece is such that you would like its tonic to be in a different position than it is. With `Shift + ←` or →`, you can move the tonic to the position you desire.

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

#### 🔄 Tip: Use This as a Fallback

If the playlist is empty or has finished playing, this setup allows users to continue interacting with the system using a physical MIDI device — no need to restart or reconfigure the backend.

---

### 🧑‍🏫 3. Teaching Mode (Null Backend)

Use this mode to visualize harmonic structures without requiring live MIDI input or audio playback.

**Configuration:** (src/constants.lua)
```lua
M.backend = "null"
```

**Manual Note Definition:**
Edit `active_notes.lua` with your desired notes:

```lua
-- Manually defined active MIDI notes
return {
    60, 64, 67, -- C major triad
}
```

This mode is ideal for instructors, presentations, or debugging visual harmony logic.

---

## 🎮 Keybindings & Controls

Once launched, you can drive playback, toggle modes, and open the command menu with these keys:

### Playback Controls

| Key     | Function                                  |
|---------|-------------------------------------------|
| p       | Toggle play / pause                       |
| tab     | Play current song from start              |
| Enter   | Move to next song                         |
| h       | Toggle “instant” vs “offset” note-off mode|
| d       | Toggle debug overlay (FPS, camera info, note OFF mode)   |
| Ctrl + Q       | Quit                       |

### Command-Menu Controls

| Key         | Function                                                                                       |
|-------------|------------------------------------------------------------------------------------------------|
| :           | Open the command menu                                                                          |
| a  | Set tempo in BPM                                                                               |
| b  | Set relative speed (e.g. `0.5` = half speed)                                                   |
| c           | Play through the file once, then repeat it `<count>` more times. `<count>` = `0` cancels loop, `<count> = -1` infinite loop |
| d           | Jump to absolute tick within current MIDI file. The length of a quarter note on 100BPM has 600 ticks.|
| e  | Send raw commands to Fluidsynth (run fluidsynth in a terminal and type `help` for commands)    |

---

## 📖 Documentation

- [Feature Overview & Configuration](docs/FEATURES_AND_CONFIG.md)  
- [Full Keybindings Reference](docs/KEYBINDINGS.md)
- [For Developers - A.I generated ldoc documantation](https://jimishol.github.io/ldoc/)

---

## 🔄 Fluidsynth Backend Integration

The Fluidsynth backend is launched as a separate thread and communicates with the main visualizer via shared Lua channels. It handles MIDI playback and tracks active notes in real time.

### 🧠 How It Works

- A thread spawns the Fluidsynth process using platform-specific commands.
- Fluidsynth outputs `noteon` and `noteoff` events to its terminal (`stdout`).
- The thread reads these events line-by-line and maintains a table of currently active notes.
- These notes are written to `active_notes.lua`, which the main thread reads to render harmony in 3D.

### 📁 Output Format

The `active_notes.lua` file is auto-generated and looks like this:

```lua
-- Auto‐generated active MIDI notes
return {
    60, 64, 67, -- C major triad
}
```

### ⚙️ Configuration Channels

The backend thread receives its configuration via Love2D thread channels:

| Channel Name      | Purpose                          |
|-------------------|----------------------------------|
| `backend`         | Executable name (e.g. `fluidsynth`) |
| `soundfonts`      | Path to the SoundFont file       |
| `songs`           | Comma-separated list of MIDI files |
| `shellPort`       | TCP port for backend control     |
| `shellHost`       | Hostname/IP of backend           |
| `platform`        | OS identifier (`windows`, `linux`, etc.) |
| `track_control`   | Signal to clear active notes     |

### 🧪 Notes on Stability

This system depends on:
- FluidSynth emitting clean, parseable output
- Channels being correctly populated before launch
- The subprocess staying alive and responsive

If any part fails (e.g. malformed output, missing soundfont, broken pipe), the tracker may silently stop updating. For this reason, a fallback mode (`null` backend) is available for manual control.

---

## 💬 Community & Discussions

Your feedback drives this project! Join one of our GitHub Discussions below:

- 💭 [Project's Usage & Feedback](https://github.com/jimishol/cholidean-harmony-structure/discussions/categories/project-s-usage-feedback) –  share your experiences and questions about the project itself. 
- 🎼[Interpretation of structure](https://github.com/jimishol/cholidean-harmony-structure/discussions/categories/interpretation-of-structure) – Share ideas on different interpretations of the structure’s elements.

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

---

## Acknowledgments 🙏

This project took shape thanks to the insight and encouragement of [**Edgar Delgado Vega**](https://github.com/edelveart).

Although the idea had been explored by 20th‑century music–math theorists, it was only when E.D.V. encountered the concept that he immediately recognized its potential for new approaches in 12ET harmony. He urged me to share it more widely and encouraged me to bring it into academic and creative circles. 

That encouragement transformed a dormant idea into a living project. From OpenSCAD to MeshLab, to Blender, to 3DreamEngine, to MIDI events, each stage brought new challenges and discoveries. Without E.D.V.’s vision and determination, this journey might never have begun.
