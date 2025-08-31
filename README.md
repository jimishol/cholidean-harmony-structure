# Cholidean Harmony Structure

[![Theme Image](https://github.com/jimishol/jimishol.github.io/raw/main/tonality/cholidean_structure.png)](https://github.com/jimishol/jimishol.github.io/blob/main/tonality/cholidean_structure.png)

This is a [video screen record](https://jimishol.github.io/tonality/cholidean-harmony-structure.webm).

Cholidean Harmony Structure projects 12-tone Equal Temperament (12ET) music systems into 3D space. Each tone sits on a parametric closed curve, forming a two-dimensional surface strip that wraps around an [umbilic torus](https://en.wikipedia.org/wiki/Umbilic_torus). Integration with [FluidSynth](https://github.com/FluidSynth/fluidsynth) as a MIDI backend demonstrates a powerful way to visualize and explore harmony theories.

---

## Two Ways Into This World

- **The Watch and the Twelve Realms** — read the origin fable in [the_story.md](docs/the_story.md) (or first watch the story at https://jimishol.github.io/post/circle_of_fifths).  
- **Tonality Structure in Music** — read the tonal structure article at https://jimishol.github.io/post/tonality/.

---

## Installation Prerequisites and Steps 🚀

This project embeds [3DreamEngine](https://github.com/3dreamengine/3DreamEngine) — an awesome 3D engine for LÖVE (Love2D) — directly in its codebase. You only need to install LÖVE to run the project; no separate 3DreamEngine install is required.

### Linux

1. Install LÖVE:  
   ```bash
   sudo zypper install love
   ```
2. Run from the project root:  
   ```bash
   love .
   ```
   or
   ```bash
   ./run.sh
   ```
   (the script enables restart capability)
3. To enable MIDI playback, install FluidSynth:  
   ```bash
   sudo zypper install fluidsynth
   ```
4. Download a SoundFont, e.g. `FluidR3_GM.sf2`, and place it in the project root (or install via your package manager):
   ```bash
   sudo zypper install fluid-soundfont-gm
   ```

### macOS (Untested)

1. Install via Homebrew:
   ```bash
   brew install love
   brew install fluidsynth
   ```
2. Run:
   ```bash
   love .
   ```
   _Note: macOS support is unverified. Feedback or contributions are welcome._

### Windows

> **Note:** Review the **Known Issues** below. For just exploring the structure, set `M.backend = "null"` in `src/constants.lua` and skip steps 3–5.

1. Clone or unzip the release archive.
2. Install LÖVE: Download the portable zip from https://love2d.org/ and extract into the project directory so that `love.exe` sits next to `main.lua`.
3. Install FluidSynth: Download the Windows zip from https://github.com/FluidSynth/fluidsynth/releases and extract into the project directory (creates `bin/`, `lib/`, `include/`).
4. Add a SoundFont: Download `FluidR3_GM.sf2` and place it next to `main.lua`.
5. Install Git for Windows (necessary for `winpty`), reboot, then launch:
   ```bat
   run.bat
   ```

#### Known Issues

- **Line-buffered output isn’t working** under Windows, so active-note events may batch or delay.  
- **No spaces in song filenames**: rename files or use underscores (e.g. `My_Song.mid`).  
- **Restart-on-exit disabled**: Windows’ `winpty` layer doesn’t propagate exit codes.

---

## Prerequisites

This repo uses Git LFS for large assets. Install and enable it before cloning:

```bash
# macOS (Homebrew)
brew install git-lfs

# Windows (Chocolatey)
choco install git-lfs

# Debian/Ubuntu
sudo apt-get install git-lfs

# Initialize
git lfs install
```

---

## Basic Usage & Developer Integration

### For Regular Users

This is a minimalist music player that projects harmony into 3D:

- Supports MIDI files via FluidSynth  
- Interactive controls for play/pause, tempo, and debugging  
- No extra setup: just launch and load a MIDI file

### For Backend Developers

Backends now stream active notes directly to the note-state server via TCP. No disk writes are required.

#### 🔄 Live TCP Note Tracking

All backends — including Fluidsynth, telnet, and external tools — communicate with the note-state server at:

```
localhost:9810
```

If your tool or backend can emit a comma-separated list of active MIDI notes (e.g. `60,64,67`), you can connect to this port and stream updates directly. The `"null"` backend enables this mode and requires no Lua integration.

🎶 Harmony can be visualized not only from MIDI, but also from audio formats like `.mp3`, `.ogg`, `.wav`, or even live concert feeds — as long as the system can extract and expose active notes via TCP.

---

## Keybindings & Controls 🎮

### Playback

| Key         | Function                              |
| ----------- | ------------------------------------- |
| p           | Toggle play/pause                     |
| Tab         | Play current song from start          |
| Enter       | Move to next song                     |
| h           | Toggle instant vs. offset note-off    |
| d           | Toggle debug overlay (FPS, camera, etc.) |
| Ctrl + Q    | Quit                                  |

### Command Menu

| Key | Function                                                                                  |
| --- | ----------------------------------------------------------------------------------------- |
| :   | Open command menu                                                                         |
| a   | Set tempo in BPM                                                                          |
| b   | Set relative speed (e.g., `0.5` = half speed)                                             |
| c   | Repeat play `<count>` more times (0 cancels loop, -1 = infinite)                          |
| d   | Jump to absolute tick (600 ticks = quarter note @ 100 BPM)                                |
| e   | Send raw commands to FluidSynth (`help` in its terminal)                                  |

---

## Documentation 📚

- [Feature Overview & Configuration](docs/FEATURES_AND_CONFIG.md)  
- [Full Keybindings Reference](docs/KEYBINDINGS.md)  
- [Developer Integration Guide](asset_pipeline/FOR_DEVELOPERS.md)  
- [Generated API Docs (ldoc)](https://jimishol.github.io/ldoc/)

---

## Community & Discussions 💬

- [Project Usage & Feedback](https://github.com/jimishol/cholidean-harmony-structure/discussions/categories/project-s-usage-feedback)  
- [Interpretation of Structure](https://github.com/jimishol/cholidean-harmony-structure/discussions/categories/interpretation-of-structure)

---

## License 📄

Licensed under **GNU GPL v3.0**. See [LICENSE](LICENSE) for details.

---

### Third-Party Licenses 📦

| Asset Type                | License File                                                        |
| ------------------------- | ------------------------------------------------------------------- |
| 3D Engine components      | [3dreamengine.md](THIRD_PARTY_LICENSES/3dreamengine.md)             |
| Material textures & HDRIs | [materials.md](THIRD_PARTY_LICENSES/materials.md)                   |
| MIDI files                | [midis.md](THIRD_PARTY_LICENSES/midis.md)                           |

---

## Acknowledgments 🙏

This project took shape thanks to the insight and encouragement of [Edgar Delgado Vega](https://github.com/edelveart).

Although the idea had been explored by 20th‑century music–math theorists, it was only when E.D.V. encountered the concept that he immediately recognized its potential for new approaches in 12ET harmony. He urged me to share it more widely and encouraged me to bring it into academic and creative circles.

That encouragement transformed a dormant idea into a living project. From OpenSCAD to MeshLab, to Blender, to 3DreamEngine, to MIDI events, each stage brought new challenges and discoveries. Without Edgar Delgado’s vision and determination, this journey might never have begun.
