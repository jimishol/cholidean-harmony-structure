--- Centralized configuration constants for the structure viewer project.
-- @module constants
-- @field backend               string   The engine that outputs heard notes or "null" if `active_notes.lua` is edited manually.
-- @field windowsBackendPath    string   The root path of fuidsynth that will be in ROOT of project and contain the \bin subfolder on windows
-- @field winPTYcommand        string   The absolute or relatived path for winPTY.exe
-- @field soundfonts            string   Path to the SoundFont (.sf2/.sf3) file that Fluidsynth will load for audio synthesis. Provide an absolute or project-relative path; leave empty to skip loading a soundfont.
-- @field shellPort             number   TCP port to control the backend (e.g. fluidsynth with `-s`).
-- @field shellHost             string   Hostname or IP of the backend.
-- @field bck_image             string   HDRI image used as the sky background.
-- @field day_night             number   Current simulated hour (0.00–24.00).
-- @field day_night_speed       number   Speed at which background brightness shifts with +/- keys.
-- @field maxBright             number   Maximum daytime background brightness.
-- @field maxNightBright        number   Maximum nighttime brightness.
-- @field nightLightOrigin      number   Point-light brightness at origin during night.
-- @field nightLightCamera      number   Point-light brightness at camera during night.
-- @field jointScale            number   Scale factor for imported joint meshes.
-- @field scaleFactor           number   Ratio of active vs. inactive joint sizes.
-- @field bassScale             number   Depth-offset scale for bass-note joints.
-- @field surfAlpha             number   Opacity for surface meshes.
-- @field sunBrightness         number   Intensity of the sun light.
-- @field defaultNoteMode       string   Note-mode, either `"instant"` or `"offset"`.
-- @field offsetDuration        number   Delay (s) before sending a “note-off” when in offset mode.
-- @field bassOffsetDuration    number   Delay (s) before sending a “note-off” for the bass note.
-- @field initialCameraPosition table    Starting camera position in world space.
-- @field initialCameraPosition.x number  X coordinate of initial camera.
-- @field initialCameraPosition.y number  Y coordinate of initial camera.
-- @field initialCameraPosition.z number  Z coordinate of initial camera.
-- @field autoExposure          table    Auto-exposure settings.
-- @field autoExposure.enabled  boolean  Enable/disable auto-exposure.
-- @field autoExposure.target   number   Desired average luminance.
-- @field autoExposure.speed    number   Adaptation speed for exposure.
-- @field torusRadius           number   Outer radius of the torus (must not change).
-- @field torusWidth            number   Width of the torus ring (must not change).
-- @field label_distance        number   Distance factor from triangle center to joint label.
-- @field label_scale           number   Base scale ratio for 3D labels.
-- @field label_active_scale    number   Scale ratio for active versus inactive labels.
-- @field dynamicLabelFacing    boolean  Whether labels always face the camera.
-- @field fov                   number   Vertical field-of-view (degrees).
-- @field resetDuration         number   Duration (s) of the camera orientation reset tween.
-- @field sensitivity           table    Mouse/keyboard sensitivity settings.
-- @field sensitivity.mouse_angle     number  Mouse look speed (rad/pixel).
-- @field sensitivity.mouse_height    number  Mouse vertical‐move speed.
-- @field sensitivity.mouse_zoom      number  Mouse scroll zoom multiplier.
-- @field sensitivity.invert_mouse    boolean Invert vertical mouse look.
-- @field sensitivity.keyboard_angle  number  Keyboard yaw speed (rad/s).
-- @field sensitivity.keyboard_height number  Keyboard vertical speed (units/s).
-- @field sensitivity.keyboard_fov    number  Keyboard FOV change speed (deg/s).
-- @field sensitivity.free_move       number  Free-fly movement speed (units/s).
-- @field sensitivity.free_mouse      number  Free-fly mouse drag sensitivity.
-- @field NOTE_ORDER            string[] Circle-of-fourths note sequence.
-- @field activationThreshold   number   Volume threshold for “heard” vs “unheard.”
-- @field emissionLevels        table    Emission intensities by category.
-- @field emissionLevels.joints   table  Joint emission levels (`.active`, `.inactive`).
-- @field emissionLevels.edges    table  Edge emission levels (`.active`, `.inactive`).
-- @field emissionLevels.curves   table  Curve emission levels (`.active`, `.inactive`).
-- @field emissionLevels.surfaces table  Surface emission levels (`.active`, `.inactive`).
-- @field emissionLevels.labels   table  Label emission levels (`.active`, `.inactive`).

local M = {}

M.backend             = "fluidsynth"
M.windowsBackendPath  = "bin/"
M.winPTYcommand       = "C/'Program Files'/Git/usr/bin/winpty.exe"
M.soundfonts          = "FluidR3_GM.sf2"
M.shellPort           = 9800
M.shellHost           = "localhost"

M.bck_image           = "assets/sky/DaySkyHDRI021A_4K.hdr"
M.day_night           = 8
M.day_night_speed     = 0.15
M.maxBright           = 1.40
M.maxNightBright      = 0.60
M.nightLightOrigin    = 5.0
M.nightLightCamera    = 250
M.jointScale          = 1.00
M.scaleFactor         = 1.60
M.bassScale           = 0.92
M.surfAlpha           = 0.23
M.sunBrightness       = 1.0
M.defaultNoteMode     = "instant"
M.offsetDuration      = 0.15
M.bassOffsetDuration  = 0.07

M.initialCameraPosition = {
  x = -17.3,
  y =  19.7,
  z = -17.3,
}

M.autoExposure = {
  enabled = false,
  target  = 0.18,
  speed   = 1,
}

M.torusRadius           = 7
M.torusWidth            = 3
M.label_distance        = 1.60
M.label_scale           = 0.85
M.label_active_scale    = 1.30
M.dynamicLabelFacing    = true

M.fov            = 26.8
M.resetDuration  = 0.5

M.sensitivity = {
  mouse_angle    = 0.005,
  mouse_height   = 0.05,
  mouse_zoom     = 0.1,
  invert_mouse   = false,
  keyboard_angle = 0.20,
  keyboard_height= 5,
  keyboard_fov   = 8,
  free_move      = 5.0,
  free_mouse     = 0.1,
}

M.NOTE_ORDER = {
  "C", "F", "Bb", "Eb", "Ab", "Db",
  "Gb", "B", "E", "A", "D", "G",
}

M.activationThreshold = 0.15

M.emissionLevels = {
  joints   = { active = 0.20, inactive = 0.005 },
  edges    = { active = 0.05, inactive = 0.005 },
  curves   = { active = 0.05, inactive = 0.005 },
  surfaces = { active = 0.05, inactive = 0.015 },
  labels   = { active = 0.40, inactive = 0.005 },
}

return M
