# Extended Configuration Options

---

## Audio Backend

| Option                 | Default             | Description                                   |
|------------------------|---------------------|-----------------------------------------------|
| `backend`              | `"fluidsynth"`      | External audio backend executable             |
| `windowsBackendPath`   | `"bin\\"`           | Root path of Fluidsynth on Windows (`\bin`)   |
| `shellHost`            | `"localhost"`       | Hostname or IP of the backend                 |
| `shellPort`            | `9800`              | TCP port to control the backend               |
| `soundfonts`           | `"FluidR3_GM.sf2"`  | Path to SoundFont file for Fluidsynth         |

---

## Environment & Lighting

| Option               | Default                             | Description                                             |
|----------------------|-------------------------------------|---------------------------------------------------------|
| `bck_image`          | `"assets/sky/DaySkyHDRI021A_4K.hdr"`| HDRI image used as sky background                       |
| `day_night`          | `8`                                 | Current simulated hour (0–24)                           |
| `day_night_speed`    | `0.15`                              | Speed of background brightness shift                    |
| `maxBright`          | `1.40`                              | Maximum daytime brightness                              |
| `maxNightBright`     | `0.60`                              | Maximum nighttime brightness                            |
| `nightLightOrigin`   | `5.0`                               | Point-light brightness at origin during night           |
| `nightLightCamera`   | `250`                               | Point-light brightness at camera during night           |
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
| `jointScale`         | `1.00`  | Scale factor for imported joint meshes           |
| `scaleFactor`        | `1.60`  | Ratio of active vs. inactive joint sizes         |
| `bassScale`          | `0.92`  | Depth-offset scale for bass-note joints          |
| `surfAlpha`          | `0.23`  | Opacity for surface meshes                       |
| `label_distance`     | `1.60`  | Distance factor from center to joint labels      |
| `label_scale`        | `0.85`  | Base scale ratio for 3D labels                   |
| `label_active_scale` | `1.30`  | Scale ratio for active vs. inactive labels       |
| `dynamicLabelFacing` | `true`  | Whether labels always face the camera            |

---

## Camera & Controls

| Option                     | Default                | Description                                           |
|----------------------------|------------------------|-------------------------------------------------------|
| `initialCameraPosition`    | `{-17.3, 19.7, -17.3}` | Starting world coordinates                            |
| `fov`                      | `26.8`                 | Vertical field of view (degrees)                      |
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
| `offsetDuration`        | `0.15`              | Delay before sending note-off in `"offset"` mode       |
| `bassOffsetDuration`    | `0.07`              | Delay before sending note-off for the bass note        |
| `activationThreshold`   | `0.15`              | Volume threshold for “heard” vs. “unheard”             |
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
