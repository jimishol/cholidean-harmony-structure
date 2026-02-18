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
> While the Umbilic Torus lattice is structurally neutral, this specific estimation module applies a "Common Practice" filter. It detects Keys by identifying clusters of **4 Adjacent Surfaces** (Tonic, Dominant, Subdominant, Relative).
> *   **Supported:** Standard Western Harmony (Bach to Jazz Standards).
> *   **Experimental:** Symmetric scales (Whole-Tone, Diminished) or Quartal harmony may result in unstable or `None` readings, as they do not form the specific topological cluster this tool is tuned to detect.

*I strongly encourage developers to create custom estimation modules for other harmonic geometries.*

What about that?
| Control | Action | Description |
| :--- | :--- | :--- |
| **k** | Toggle Harmonic Wake | Switches the multi-line analysis display on/off. |

### Visualization Logic
*   **The Chimney:** The display uses a bottom-up stack.
    *   **Active (Bottom):** The current geometric truth (Bright White).
    *   **History (Rising):** Previous states float upward and fade out (Grey).
*   **Relative Pairs:** Keys are displayed as geometric pairs (e.g., `G | Em`) to respect the topological unity of relative scales.
*   **Strict Veto:** The system uses "Survival of the Present" logic. If a chromatic note conflicts with the current key, the system immediately reports `None` or the new key, ensuring the display reflects the exact geometric reality of the moment.

### Status Indicators

The system provides real-time feedback on the harmonic stability of the topology:

*   **`Key: None` (Local Contradiction):**
    *   **Meaning:** The current notes form a geometrically impossible structure (e.g., mutually exclusive surfaces active simultaneously).
    *   **Result:** The system cannot determine a root for the current moment.

*   **`Key: ?` (Geometric Shear):**
    *   **Meaning:** The **Current Notes** contradict the **Harmonic History**.
    *   **Geometric Cause:** The "Wake" projects a specific Key Axis, but the current chord contains a "Veto Note" that destroys that axis.
    *   **Musical Implication:** Signals a **Deceptive Resolution**, **Modal Mixture**, or sudden modulation.
    *   **Result:** The Chimney (History) is **preserved**, acknowledging the path taken, but the current tonal center is momentarily suspended.

*   **`Key:     ` (Silence / Collapse):**
    *   **Meaning:** Harmonic energy has dissipated (No notes > 2.0s).
    *   **Result:** The Chimney is **force-cleared**. The next chord is treated as a new harmonic anchor.

---

<p align="right">
  <a href="../README.md">← Back to Main README</a>
</p>
