
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
-- Field-of-view based on 50 mm lens, 35 mm sensor (vertical)
M.fov      = 2 * math.deg(math.atan((24 * 0.5) / 50))  -- ≃ 26.8°.
M.nearClip = 0.01         -- Near plane distance
M.farClip  = 1000         -- Far plane distance

----------------------------------------
-- Initial Camera Transform (Free Movement Mode)
----------------------------------------
M.initialCameraPosition = {
  x = -15,
  y =  25,
  z =  23
}

-- Exact Blender camera rotation, as a quaternion (x, y, z, w)
M.initialCameraRotation = {
  0.2584960162639618,
  0.1216428130865097,
 -0.40803834795951843,
 -0.8671144843101501
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
