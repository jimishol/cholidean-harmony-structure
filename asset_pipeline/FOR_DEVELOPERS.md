# 💡 Developer Integration Guide

This file outlines the geometric modeling pipeline, asset preparation steps, Git subtree integrations, and backend architecture used to build the **Cholidean Harmony Structure** — a spatial-musical framework rendered in Love2D using 3DreamEngine.

---

## 🧭 Geometry Design Pipeline

### Overview

This project visualizes harmonic relationships in 12-tone equal temperament (12ET) using parametric 3D geometry and dynamic rendering. Geometry generation and refinement are handled with OpenSCAD, MeshLab, Blender, and finally consumed by Love2D.

### Workflow

1. ✳️ **OpenSCAD**  
   - Scripts: `main.scad`, `prims.scad`  
   - Models parametric dodecahedra, joints, ribbon surfaces, and curves arranged in a toroidal helix.

2. 🎛️ **Export**  
   - Use `export_tones_and_surfaces.sh` to batch-export `.stl` files.

3. 🧽 **MeshLab**  
   - Apply smoothing using the `smoothing_objects.mlx` script.

4. 🎨 **Blender**  
   - Import `.obj` files (Up Axis: Z)  
   - Assign PBR materials & HDRI (from [ambientCG](https://ambientcg.com/))  
   - Convert `.exr` backgrounds to `.hdr` via GIMP  
   - Use `.png` normal maps with Roughness = 1  
   - Export `.obj` files (Up Axis: Y)  
   - **Final Renaming for 3DreamEngine Compatibility:**  
     Rename objects by tonal label following the **circle of perfect fourths**:

     ```
     joints_C      → joint_00
     edges_F       → edge_01
     curves_Bb     → curve_02
     surfaces_Eb   → surface_03
     …
     ```
     This continues cyclically for all 12 tones, assigning suffixes `00–11` and preserving type prefixes (`joint_`, `edge_`, `curve_`, `surface_`).

   - Copy Blender’s `textures/` folder into `assets/materials_gl/materials/` and rename files accordingly, except that `*Color.png` becomes `*albedo.png`.

5. 🎮 **Love2D + 3DreamEngine**  
   - Load processed models under `assets/models/` and render with real-time shading and interactive behavior.

---

## 🎶 Harmony Structure Notes

- Each tone is represented by a **dodecahedron** on a toroidal helix (Circle of Fourths).  
- **Modulatory pathways** are represented by curves and edges.  
- The entire system is parametric and customizable.

Learn more about the theory at [Cholidean Harmony Structure blog post](https://jimishol.github.io/post/tonality/).

---

## 📦 Git Subtree Integrations

To keep the project self-contained and updatable, key third-party libraries are included using Git subtrees.

### 3DreamEngine

🗂️ Paths:

- Core: `3DreamEngine/3DreamEngine/`  
- Extensions: `3DreamEngine/extensions/`

#### 1. Initial Integration (Core)

```bash
git remote add -f 3DreamEngine https://github.com/3dreamengine/3DreamEngine.git
git merge -s ours --no-commit --allow-unrelated-histories 3DreamEngine/master
git read-tree --prefix=3DreamEngine/3DreamEngine/ -u 3DreamEngine/master:3DreamEngine
git commit -m "Merge in 3DreamEngine/3DreamEngine subtree"
```

**Update (Core)**

```bash
git fetch 3DreamEngine
git subtree pull --prefix=3DreamEngine/3DreamEngine 3DreamEngine master --squash
```

#### 2. Initial Integration (Extensions)

```bash
git read-tree --prefix=3DreamEngine/extensions/ -u 3DreamEngine/master:extensions
git commit -m "Import 3DreamEngine extensions subtree"
```

**Update (Extensions)**

```bash
git fetch 3DreamEngine
git subtree pull --prefix=3DreamEngine/extensions 3DreamEngine master --squash
```

**Tips for Development & Branching**

- Use feature branches (e.g., `insert_mats`) to test integrations before merging to `main`.  
- Commit or stash local changes before running any subtree pull.  
- Automate updates with:

  ```bash
  ./asset_pipeline/update-libs.sh
  ```

  You’ll see:
  
  ```
  ✅ All subtrees updated and version log written to asset_pipeline/lib_versions.md
  ```

⚠️ **Caution:** Avoid adding large binaries or full histories via Git LFS; keep the repo under 5 GB.

---

## 🛠️ For Backend Developers

### 🔄 Live TCP Note Tracking

The system now supports real-time MIDI note tracking via TCP. All backends — including Fluidsynth, telnet, and external tools — communicate directly with the note-state server at:

```
localhost:9810
```

If your tool or backend can emit a comma-separated list of active MIDI notes (e.g. 60,64,67), you can connect to localhost:9810 and stream updates directly. The "null" backend enables this mode and requires no disk writes or Lua integration.

🎶 Note: Harmony can be visualized not only from MIDI, but also from audio formats like .mp3, .ogg, .wav, or even live concert feeds — as long as the system can extract and expose active notes via TCP. This opens the door to real-time visualizations from DAWs, audio analysis tools, or live performance setups.

### ✅ Backend API

Each backend module (e.g., `fluidsynth.lua`, `null.lua`) must return a table with:

1. `start(config)`  
   - Launches the backend thread or subprocess.  
   - Receives a `config` table with these Love2D channel keys:
     - `backend` (string): executable name (e.g., `"fluidsynth"`)  
     - `soundfonts` (string): path to SoundFont file  
     - `songs` (string): comma-separated MIDI file list  
     - `shellHost` / `shellPort` (string/int): TCP host & port for Fluidsynth shell  
     - `noteStateHost` / `noteStatePort` (string/int): TCP host & port for note-state server  
     - `platform` (string): OS identifier (`"linux"`, `"windows"`, etc.)  
     - `track_control` (boolean): whether to clear active notes on start

2. `stop()`  
   - Gracefully stops playback, kills the subprocess or thread, and closes all channels.  
   - Invoked when switching backends or on application exit.

3. `sendCommand(cmd: string)` _(optional)_  
   - Pushes a raw command (play, pause, set tempo, etc.) to the backend’s stdin or TCP socket.

4. `quit()` _(alias of `stop()`)_  
   - Called from `love.quit()` for final cleanup.

> **Note:**  
> - `active_notes.lua` is no longer used for runtime state.  
> - All note tracking is handled via TCP.  
> - External tools do not need to be written in Lua — any environment that can open a TCP socket and send a comma-separated list of MIDI notes is compatible.

Once implemented, the core engine will:
- Spawn your backend in a Love2D thread  
- Manage shared channels  
- Merge note input from all clients for unified visualization

That’s it — drop your Lua module in `src/backends/`, follow this API, and your backend will “just work.” 🎹🔗
