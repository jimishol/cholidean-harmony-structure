
-- src/constants.lua
-- Centralized configuration constants for the structure viewer project.
-- @module constants

local M = {}

M.brightness  = 0.5 -- background environment brightness
M.scaleFactor = 1.6
M.surfAlpha   = 0.17
M.threshold   = 0.5

-- Torus geometry parameters
-- @field torusRadius Outer radius of torus
-- @field torusWidth Width of torus ring
-- @field steps Number of segment steps (for rendering resolution)
M.torusRadius = 7
M.torusWidth  = 3
M.steps       = 16

-- Tone marker options
-- @field ballRadius Radius of tone spheres placed on geometry
M.ballRadius = 1.5

-- Spiral of Fifths rendering options
-- @field rope_radius Radius of spiral curve
-- @field rope_sides Number of sides for rope (polygonal resolution)
-- @field monoSegment Whether to render single-tone segment only
-- @field monoSegmentColor Color of mono segment (RGB)
-- @field glassAlpha Alpha transparency for glass overlay
M.rope_radius      = 0.12
M.rope_sides       = 6
M.monoSegment      = false
M.monoSegmentColor = { r = 255, g = 255, b = 255 }
M.glassAlpha       = 0.3

-- Camera projection settings for 3DreamEngine
-- @field fov Vertical field-of-view in degrees (simulates 50 mm lens)
-- @field nearClip Distance to near clipping plane
-- @field farClip Distance to far clipping plane
M.fov      = 26.8
M.nearClip = 0.01
M.farClip  = 1000

-- Initial camera placement
-- @field initialCameraPosition Initial camera position in world space
-- @field xAt Target point X (for orbit mode or framing)
-- @field yAt Target point Y
-- @field zAt Target point Z
M.initialCameraPosition = {
  x = -18,
  y = 28,
  z = -23
}

M.xAt = 0
M.yAt = 0
M.zAt = 0

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

return M
