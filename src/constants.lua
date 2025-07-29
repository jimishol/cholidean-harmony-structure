-- src/constants.lua
-- Centralized configuration constants for the structure viewer project.
-- @module constants

local M = {}
M.bck_image	  = "assets/sky/DaySkyHDRI021A_4K.hdr"
M.day_night       = 8    -- Hour (float) 0:00-24:0.05
M.day_night_speed = 0.15 -- greater value faster change of background brightness by +/- keys
M.maxBright       = 1.40 -- maximum acceptable background brightness
M.maxNightBright  = 0.60 -- maximum night bright (supposedly by moon)
M.nightLightOrigin = 3.0 -- how bright is the point light on origin
M.nightLightCamera = 160 -- how bright is the point light on camera
M.jointScale      = 1.00 -- Factor to scale imported joints
M.scaleFactor     = 1.60 -- scale ratio of active joints
M.surfAlpha       = 0.17
M.threshold       = 0.5  -- With larger active value activation effect will be on
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
M.torusRadius    = 7
M.torusWidth     = 3
M.label_distance = 1.5  -- factor the distance from center of augmented third triangles to respective joint
M.label_scale    = 0.85  -- ratio on imported initial size of 3D labels.
M.dynamicLabelFacing = true  -- whether labels rotate to face the camera

-- Camera projection settings for 3DreamEngine
-- @field fov Vertical field-of-view in degrees (simulates 50 mm lens)
M.fov      = 26.8

-- Initial camera placement
-- @field initialCameraPosition Initial camera position in world space
-- @field xAt Target point X (for orbit mode or framing)
-- @field yAt Target point Y
-- @field zAt Target point Z
M.initialCameraPosition = {
  x = -15.5,
  y =  20.0,
  z = -22.0
}

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

  keyboard_angle  = 0.18,
  keyboard_height = 5,
  keyboard_zoom   = 5.0,
  keyboard_fov    = 8,

  free_move  = 5.0,
  free_mouse = 0.1
}

M.NOTE_ORDER = {
  "C", "F", "Bb", "Eb", "Ab", "Db",
  "Gb", "B", "E", "A", "D", "G"
}

-- Emission strength when a note is active (0.0–1.0)
M.activeEmission       = 0.75

-- Optional: per‐category emission multipliers
M.categoryEmission = {
  joints   = 1.0,  -- 1.0 × activeEmission
  edges    = 0.6,  -- 0.6 × activeEmission
  curves   = 0.6,
  surfaces = 0.4,
  labels   = 0.0,  -- labels never glow
}

return M
