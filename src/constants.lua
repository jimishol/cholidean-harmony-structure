--- Various constants or options.
-- This module provides various settings that can be used across the project.
-- It includes constants for tuning numerical values such as scaling, offsets, or any
-- other purpose as required.
-- @module constants

local M = {}

--- Torus options
-- Constant used for defining the 'radius' of the torus.
M.torusRadius = 7
-- Constant used for defining the 'width' of the torus.
M.torusWidth = 3
-- Steps constant used for defining the smoothness of the torus.
M.steps = 16 -- steps of each segment of a perfect fifth

--- Tones as ball options
--- Constant used for defining the radius of ball for each tone
M.ballRadius = 1.5

--- Spiral of Fifths options
M.rope_radius = 0.12   -- radious of the closed 'rope' that forms the 3D Spiral of Fifths
M.rope_sides  = 6    -- >=3 'sides' of the closed 'rope' that forms the 3D Spiral of Fifths
M.monoSegment = true
M.monoSegmentColor = { r = 255, g = 255, b = 255 }  -- default color (white)
M.glassAlpha = 0.3 -- Fixed alpha for a glass-like transparent appearance.

--- Camera options
M.distance  = 16   -- How far the camera is from the origin (R).
M.elevation = 73   -- Elevation in degrees.
M.azimuth   = 22   -- Azimuth in degrees.
M.fov       = math.pi/2    -- Field of View, and is an angle in radians specifying how "wide" your camera is
M.nearClip = 0.01  -- denoting how far your Near Clipping Plane is from your camera's position.
M.farClip = 1000   -- denoting how far your Far Clipping Plane is from your camera's position.
M.up_unit_vector = {0, -1, 0} -- represents which way up is.
M.xAt	    = 0	   -- the x coordinate of the position where the camera look.
M.yAt	    = 0	   -- the y coordinate of the position where the camera look.
M.zAt	    = 0	   -- the z coordinate of the position where the camera look.

return M
