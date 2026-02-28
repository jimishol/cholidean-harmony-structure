[Back to Main README](../README.md)

# Extended Configuration Options

---

## Audio Backend

| Option                 | Default             | Description                                                                                                      |
|------------------------|---------------------|------------------------------------------------------------------------------------------------------------------|
| `backend`              | `"fluidsynth"`      | External audio backend executable                                                                                |
| `windowsBackendPath`   | `"bin\\"`           | Root path of Fluidsynth on Windows (`bin\`)                                                                      |
| `DEFAULT_MIDI_PORT`    | `"14:0"`            | Default MIDI input port for active‑note tracking (Linux ALSA: `"14:0"`, Windows: name of virtual cable/device)   |
| `shellHost`            | `"localhost"`       | Hostname or IP of the backend                                                                                    |
| `shellPort`            | `9800`              | TCP port to control the backend                                                                                  |
| `soundfonts`           | `"FluidR3_GM.sf2"`  | Path to SoundFont file                                                                            |

---

## Environment & Lighting

| Option               | Default                             | Description                                             |
|----------------------|-------------------------------------|---------------------------------------------------------|
| `bck_image`          | `"assets/sky/DaySkyHDRI021A_4K.hdr"`| HDRI image used as sky background                       |
| `day_night`          | `8`                                 | Current simulated hour (0–24)                           |
| `day_night_speed`    | `0.15`                              | Speed of background brightness shift                    |
| `maxBright`          | `1.40`                              | Maximum daytime brightness                              |
| `maxNightBright`     | `0.60`                              | Maximum nighttime brightness                            |
| `nightLightOrigin`   | `5.0`                               | Point-light brightness at origin          |
| `nightLightCamera`   | `250`                               | Point-light brightness at camera           |
| `sunBrightness`      | `1.0`                               | Intensity of the sun light                              |

### Auto-Exposure

| Option                     | Default  | Description                          |
|----------------------------|----------|--------------------------------------|
| `autoExposure.enabled`     | `false`  | Enable or disable auto-exposure      |
| `autoExposure.target`      | `0.18`   | Desired average luminance            |
| `autoExposure.speed`       | `1`      | Adaptation speed for exposure        |

### Torus Geometry

| Option        | Default | Description                               |
|---------------|---------|-------------------------------------------|
| `torusRadius` | `7`     | Outer radius of the torus (fixed)         |
| `torusWidth`  | `3`     | Width of the torus ring (fixed)           |

---

## Mesh & Labels

| Option               | Default | Description                                      |
|----------------------|---------|--------------------------------------------------|
| `jointScale`         | `1.00`  | Scale factor for inactive joint meshes           |
| `scaleFactor`        | `1.60`  | Ratio of active vs. inactive joint sizes         |
| `bassScale`          | `0.92`  | Ratio of bass-note rotated joint vs normal inactive joint          |
| `surfAlpha`          | `0.23`  | Opacity for inactive surface meshes                       |
| `label_distance`     | `1.60`  | Distance factor for labels (from augmented triangle center to relative joint)       |
| `label_scale`        | `0.85`  | Base scale ratio for 3D labels vs what initially imported              |
| `label_active_scale` | `1.30`  | Scale ratio for active vs. inactive labels       |
| `dynamicLabelFacing` | `true`  | Whether labels always face the camera            |

---

## Camera & Controls

| Option                     | Default                | Description                                           |
|----------------------------|------------------------|-------------------------------------------------------|
| `initialCameraPosition`    | `{-17.3, 19.7, -17.3}` | Starting world coordinates                            |
| `fov`                      | `26.8`                 | Field Of View (degrees)                      |
| `resetDuration`            | `0.5`                  | Tween duration to reset camera orientation            |

### Sensitivity Settings

| Option                       | Default   | Description                                         |
|------------------------------|-----------|-----------------------------------------------------|
| `sensitivity.mouse_angle`    | `0.005`   | Rotation speed on right-mouse drag (rad/pixel)      |
| `sensitivity.mouse_height`   | `0.05`    | Vertical pan speed (units/pixel)                    |
| `sensitivity.mouse_zoom`     | `0.1`     | Mouse scroll zoom multiplier                        |
| `sensitivity.invert_mouse`   | `false`   | Invert vertical mouse look                          |
| `sensitivity.keyboard_angle` | `0.20`    | Rotation speed with arrow keys (rad/s)              |
| `sensitivity.keyboard_height`| `5`       | Vertical movement speed (units/s)                   |
| `sensitivity.keyboard_fov`   | `8`       | FOV change speed (deg/s)                            |
| `sensitivity.free_move`      | `5.0`     | Free-fly movement speed (units/s)                   |
| `sensitivity.free_mouse`     | `0.1`     | Free-fly mouse drag sensitivity                     |

---

## Playback & Notes

| Option                  | Default             | Description                                            |
|-------------------------|---------------------|--------------------------------------------------------|
| `defaultNoteMode`       | `"instant"`         | Note mode: `"instant"` or `"offset"`                   |
| `offsetDuration`        | `0.15`              | Delay before sending note-off in `"offset"` mode in seconds      |
| `bassOffsetDuration`    | `0.07`              | Delay before sending note-off for the bass note        |
| `auto_advance_timeout` | `5.0` | Duration of silence in seconds before the playlist automatically advances to the next song |
| `activationThreshold`   | `0.15`              | Volume threshold for “heard” vs. “unheard” UNUSED as volume information after note OFF was not possible.             Note Mode and offset duration used instead.|
| `NOTE_ORDER`            | Circle of fourths   | `["C","F","Bb","Eb","Ab","Db","Gb","B","E","A","D","G"]` |
---

## Emission Levels

| Category  | Active  | Inactive | Description                   |
|-----------|---------|----------|-------------------------------|
| `joints`  | `0.20`  | `0.005`  | Joint emission levels         |
| `edges`   | `0.05`  | `0.005`  | Edge emission levels          |
| `curves`  | `0.05`  | `0.005`  | Curve emission levels         |
| `surfaces`| `0.05`  | `0.015`  | Surface emission levels       |
| `labels`  | `0.40`  | `0.005`  | Label emission levels         |

---

## Real-Time Analysis

The system includes a geometric **Key Estimation** module that analyzes the active surface topology in real-time. This feature visualizes the "Harmonic Wake"—the trajectory of the lattice as it moves through the Circle of Fourths.

> **NOTE: Topological Bias (Western Tonality)**
> While the Umbilic Torus lattice is structurally neutral, this specific estimation module applies a "Common Practice" filter. It detects Keys by identifying **Topological Axes** defined by the **Dominant (t-1)** and **Torque (t+2)** surfaces.
> *   **Supported:** Standard Western Harmony (Bach to Jazz Standards).
> *   **Experimental:** Symmetric scales (Whole-Tone, Diminished) or Quartal harmony may result in **`None`** or split readings (e.g., `Dm F#m`), as they do not form the specific topological container this tool is tuned to detect.

| Control | Action | Description |
| :--- | :--- | :--- |
| **k** | Toggle Harmonic Wake | Switches the multi-line analysis display on/off. |

### Visualization Logic

*   **The Chimney:** The display uses a bottom-up stack.
    *   **Active (Bottom):** The current geometric truth.
    *   **History (Rising):** Previous states float upward and fade out, representing the "Wake" of the harmonic movement.
*   **Mode-Agnostic Detection:**
    *   The system identifies the **Diatonic Neighborhood** (Parent Scale) rather than enforcing a strict Tonic anchor.
    *   *Example:* A **D Dorian** progression (`Dm` <-> `G`) will be identified as **`C | Am`**, as it geometrically resides within the C-Major axis boundaries.
    *   *Ghostbuster Veto:* To prevent false positives, the system rejects Major Keys if the **Parallel Minor 3rd** is present without the Major 3rd (e.g., `Am` will never trigger "A Major").
*   **Harmonic Resolution:**
    *   **Dynamic Minor Force:** The system forces the **Minor** label (`Am`) when the Harmonic Tension (t+8) **resolves** (moves from History to Inactive).
    *   **The Diminished Exception:** A standalone Dominant (`E7`) forces Minor, while a Diminished 7th (`B°7`) allows ambiguity (`C | Am`) because it contains the Subdominant note (t+1), creating a Plagal geometric opening.

### Status Indicators

The system provides real-time feedback on the harmonic stability of the topology using color codes:

*   **`Key: C | Am` (Valid):**
    *   **Meaning:** A stable, valid topological axis is established.
    *   **Behavior:** The system displays the Key (or Relative Pair).

*   **`Key: None` (Geometric Conflict):**
    *   **Meaning:** The current notes contradict the laws of the active Axis.
    *   **Causes:**
        1.  **The Veto:** Playing a "Wall" note (e.g., Lydian `#4` or Mixolydian `b7`) against a Major triad.
        2.  **Geometric Saturation:** The input activates contradictory vetoes across all potential axes (e.g., Whole-Tone Scale or Chromatic Clusters).
    *   **Result:** The system refuses to guess and reports the contradiction.

*   **`Key:     ` (Silence / Collapse):**
    *   **Meaning:** Harmonic energy has dissipated (No notes > 2.0s).
    *   **Result:** The Chimney is **force-cleared**. The next chord is treated as a new harmonic anchor, free from previous context.

---

## Playlist Automation (Auto-Advance)

The system features an automated playlist manager that monitors harmonic activity.
*   **Timeout:** If no notes are detected for a specific duration, the system automatically advances to the next song.
*   **Configuration:** The duration is controlled by `constants.auto_advance_timeout` (default: `5.0` seconds).
*   **Logic:** Automation is active during normal playback but is automatically disabled when the user enters **Teacher Mode** (`Shift + Return`), allowing for uninterrupted manual demonstrations.

### FluidSynth Backend Architecture
To ensure stability and clean state management, the FluidSynth backend uses a **Process-per-Song** iteration model:
*   Each MIDI file is played by a fresh FluidSynth instance.
*   The system performs a TCP bind-test before launching a new process to ensure the communication port is fully released by the OS.
*   This architecture prevents "stuck notes" and memory leaks across long-running playlists.

## Visualizer States

### Power-Saving Pause (Freeze Mode)
Pressing `p` toggles a high-efficiency state:
*   **Visuals:** The 3D engine captures the current frame and stops all rendering calls, significantly reducing GPU/CPU load.
*   **Audio:** The MIDI sequencer is paused.
*   **Synchronization:** Changing the song via `Tab` or `Return` automatically exits Freeze mode to ensure visuals and audio remain synchronized.

---

<p align="right">
  <a href="../README.md">← Back to Main README</a>
</p>
