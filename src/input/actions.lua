-- src/input/actions.lua

-- High‐level action constants for both keyboard & MIDI inputs.
-- Mirror the keys & behaviors used in camera.lua (and beyond).

local A = {}

-- Application control
A.QUIT           = "quit"
A.RESET_VIEW     = "reset_view"    -- reset camera orientation
A.RESET_FOV      = "reset_fov"
A.TOGGLE_DEBUG   = "toggle_debug" -- Toggle FPS + camera position (yaw/pitch) overlay

-- Label controls
A.TOGGLE_LABELS   = "toggle_labels"
A.TOGGLE_JOINTS   = "toggle_joints"
A.TOGGLE_EDGES    = "toggle_edges"
A.TOGGLE_CURVES   = "toggle_curves"
A.TOGGLE_SURFACES = "toggle_surfaces"

-- Shift-based rotation of the 12-note map
A.ROTATE_CW      = "rotate_cw"
A.ROTATE_CCW     = "rotate_ccw"

-- Camera movement (continuous)
A.MOVE_FORWARD   = "move_forward"
A.MOVE_BACKWARD  = "move_backward"
A.STRAFE_LEFT    = "strafe_left"
A.STRAFE_RIGHT   = "strafe_right"

-- Camera rotation (continuous)
A.ROTATE_LEFT    = "rotate_left"
A.ROTATE_RIGHT   = "rotate_right"
A.PITCH_UP       = "pitch_up"
A.PITCH_DOWN     = "pitch_down"

-- Zoom control
A.ZOOM_IN        = "zoom_in"
A.ZOOM_OUT       = "zoom_out"

A.TOGGLE_TORUS_LIGHTS = "toggle_torus_lights"

A.TOGGLE_NOTE_MODE = "toggle_note_mode"

return A
