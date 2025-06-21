
--- Various constants or options.
-- This module provides settings used across the project.
-- Adjust parameters below to tweak behavior in one central location.
-- Old parameters from previous "tries" have been retained as comments where they might still be useful.
-- @module constants

local M = {}

----------------------------------------
-- Torus options
----------------------------------------
M.torusRadius = 7           -- Constant for the torus 'radius'.
M.torusWidth = 3            -- Constant for the torus 'width'.
M.steps = 16                -- Steps of each segment (used in some experiments).

----------------------------------------
-- Tones as Ball options
----------------------------------------
M.ballRadius = 1.5          -- Radius of the ball representing each tone.

----------------------------------------
-- Spiral of Fifths options
----------------------------------------
M.rope_radius = 0.12        -- Radius of the closed 'rope' that forms the 3D Spiral of Fifths.
M.rope_sides  = 6           -- Number of sides (>=3) of the closed 'rope'.
M.monoSegment = true
M.monoSegmentColor = { r = 255, g = 255, b = 255 }  -- default color (white)
M.glassAlpha = 0.3          -- Fixed alpha for a glass-like transparent appearance.

----------------------------------------
-- Camera options (for 3DreamEngine)
----------------------------------------
M.distance  = 16            -- How far the camera is from the origin (R).
M.elevation = 73            -- Elevation in degrees.
M.azimuth   = 22            -- Azimuth in degrees.
M.fov       = math.pi/2     -- Field Of View (in radians).
M.nearClip  = 0.01          -- Near clipping plane distance.
M.farClip   = 1000          -- Far clipping plane distance.
M.up_unit_vector = {0, -1, 0} -- Defines which direction is 'up'.
M.xAt = 0                   -- X coordinate where the camera looks at.
M.yAt = 0                   -- Y coordinate where the camera looks at.
M.zAt = 0                   -- Z coordinate where the camera looks at.

----------------------------------------
-- Orbit Camera Control settings (NEW)
----------------------------------------
M.orbit = {
  initial_angle  = 0,        -- Initial orbit angle in radians.
  initial_radius = 10,       -- Initial distance from the scene center (zoom level).
  initial_height = 3,        -- Initial vertical offset of the camera.
  orbit_speed    = math.pi / 4, -- Automatic orbit speed (45° per second).
  -- Old value (trial): speed = 0.1
}

----------------------------------------
-- Input Sensitivity settings (NEW)
----------------------------------------
M.sensitivity = {
  -- Mouse sensitivity parameters (for relative mouse motion)
  mouse_angle  = 0.005,      -- Mouse horizontal sensitivity for orbit angle adjustment.
  mouse_height = 0.05,       -- Mouse vertical sensitivity for orbit height adjustment.
  mouse_zoom   = 0.1,        -- Mouse zoom speed (when using MMB drag).
  
  -- Keyboard sensitivity parameters (for digital input via keys)
  keyboard_angle  = 0.05,    -- Keyboard left/right sensitivity for orbit angle adjustment.
  keyboard_height = 0.5,     -- Keyboard up/down sensitivity (without shift) for orbit height.
  keyboard_zoom   = 1.0,     -- Keyboard zoom sensitivity (when shift is held with up/down).
  -- Old attempts (trial values): angle = 0.01, height = 0.1, zoom = 0.5
}

return M
