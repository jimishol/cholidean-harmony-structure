-- src/constants.lua
-- Centralized configuration constants for the structure viewer project.
-- @module constants

local M = {}

M.backend = "fluidsynth" -- the engine that outputs the heard notes
M.soundfonts = {"assets/FluidR3_GM.sf2"}
-- Initial camera placement
-- @field initialCameraPosition Initial camera position in world space
M.initialCameraPosition = {
  x = -17.3,
  y =  19.7,
  z = -17.3
}

M.bck_image	  = "assets/sky/DaySkyHDRI021A_4K.hdr"
M.day_night       = 8    -- Hour (float) 0:00-24:0.05
M.day_night_speed = 0.15 -- greater value faster change of background brightness by +/- keys
M.maxBright       = 1.40 -- maximum acceptable background brightness
M.maxNightBright  = 0.60 -- maximum night bright (supposedly by moon)
M.nightLightOrigin = 3.0 -- how bright is the point light on origin
M.nightLightCamera = 175 -- how bright is the point light on camera
M.jointScale      = 1.00 -- Factor to scale imported joints
M.scaleFactor     = 1.60 -- Ratio of active over inactive joints
M.bassScale	  = 0.92 -- Ratio of rotated bass joints over active/ Defines how much of the bass corners pops out.   
M.surfAlpha       = 0.23
M.sunBrightness   = 1.0
M.autoExposure = {
  enabled = false,     -- true to turn on, false to turn off
  target  = 0.18,     -- desired average luminance
  speed   = 1,     -- adaptation speed
}

-- Torus geometry parameters
-- @field torusRadius Outer radius of torus
-- @field torusWidth Width of torus ring
-- @field steps Number of segment steps (for rendering resolution)
M.torusRadius    = 7 -- SHOULD NOT BE ALTERED. Else joints and labels will disconnect from rest of structure
M.torusWidth     = 3 -- SHOULD NOT BE ALTERED. Else joints and labels will disconnect from rest of structure
M.label_distance = 1.60  -- factor the distance from center of augmented third triangles to respective joint
M.label_scale    = 0.85  -- ratio on imported initial size of 3D labels.
M.label_active_scale = 1.3 -- label size ratio between active and incative tones 
M.dynamicLabelFacing = true  -- whether labels rotate to face the camera

-- Camera projection settings for 3DreamEngine
-- @field fov Vertical field-of-view in degrees (simulates 50 mm lens)
M.fov      = 26.8

-- Time duration (seconds) for orientation reset tween
-- @field resetDuration Duration in seconds to interpolate orientation reset
M.resetDuration = 0.5

-- Sensitivity values for camera and input controls
-- @table sensitivity
-- @field mouse_angle Mouse sensitivity for angle (radians per pixel)
-- @field mouse_height Mouse vertical translation speed
-- @field mouse_zoom Mouse scroll zoom multiplier
-- @field invert_mouse Whether to invert mouse look (boolean)
-- @field keyboard_angle Keyboard angle increment (radians per second)
-- @field keyboard_height Vertical movement speed (units per second)
-- @field keyboard_zoom Zoom amount using keys (units per second)
-- @field keyboard_fov Amount to change FOV per second with keys
-- @field free_move Speed in free-fly mode
-- @field free_mouse Sensitivity of free-fly mouse drag
M.sensitivity = {
  mouse_angle   = 0.005,
  mouse_height  = 0.05,
  mouse_zoom    = 0.1,
  invert_mouse  = false,

  keyboard_angle  = 0.20,
  keyboard_height = 5,
  keyboard_fov    = 8,

  -- forward - backward move by keyboard
  free_move  = 5.0,
  free_mouse = 0.1
}

M.NOTE_ORDER = {
  "C", "F", "Bb", "Eb", "Ab", "Db",
  "Gb", "B", "E", "A", "D", "G"
}

-- global volume cutoff for “heard” vs “unheard”
M.activationThreshold = 0.15

-- emission strengths by category:
--   .active   when hitVolume ≥ activationThreshold
--   .inactive when hitVolume <  activationThreshold
M.emissionLevels = {
  joints   = { active = 0.20, inactive = 0.005},
  edges    = { active = 0.05, inactive = 0.005},
  curves   = { active = 0.05, inactive = 0.005},
  surfaces = { active = 0.10, inactive = 0.015},
  labels   = { active = 0.40, inactive = 0.005},
}

M.defaultNoteMode    = "offset" -- delayed turning OFF after note OFF event 

M.offsetDuration     = 0.20 -- offset to delay OFF in seconds. At 120BPM 1 eigth lasts 0.25 seconds. 
M.bassOffsetDuration = 0.10 -- offsey to delay OFF the bass tone in seconds.

return M
