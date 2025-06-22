
-- src/constants.lua
-- Centralized configuration constants for the project.

local M = {}

----------------------------------------
-- Torus Options
----------------------------------------
M.torusRadius = 7
M.torusWidth  = 3
M.steps       = 16

----------------------------------------
-- Tones as Ball Options
----------------------------------------
M.ballRadius = 1.5

----------------------------------------
-- Spiral of Fifths Options
----------------------------------------
M.rope_radius      = 0.12
M.rope_sides       = 6
M.monoSegment      = false
M.monoSegmentColor = { r = 255, g = 255, b = 255 }
M.glassAlpha       = 0.3

----------------------------------------
-- Camera Projection Settings (3DreamEngine)
----------------------------------------
M.fov      = 45           -- Initial field of view (degrees)
M.nearClip = 0.01         -- Near plane distance
M.farClip  = 1000         -- Far plane distance

----------------------------------------
-- Initial Camera Transform (Free Movement Mode)
----------------------------------------
M.initialCameraPosition = {
  x = 5,
  y = 5,
  z = 5
}

-- Target point (for completeness; not actively used in free mode)
M.xAt = 0
M.yAt = 0
M.zAt = 0

M.resetDuration = 0.5    -- Duration (in seconds) for camera orientation reset when pressing space.

-- Input Sensitivity Settings
----------------------------------------
M.sensitivity = {
  -- Mouse sensitivity (for orbit/legacy)
  mouse_angle   = 0.005,
  mouse_height  = 0.05,
  mouse_zoom    = 0.1,
  invert_mouse  = false,

  -- Keyboard input (orbit/legacy)
  keyboard_angle  = 0.18,
  keyboard_height = 5,
  keyboard_zoom   = 5.0,
  keyboard_fov    = 8,

  -- Free-move camera mode
  free_move  = 5.0,    -- Units per second
  free_mouse = 0.1     -- Units per pixel
}

return M
