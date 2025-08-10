--- High‐level input action constants for keyboard and MIDI events.
-- Mirrors the keys and behaviors used in camera.lua and other systems.
--
-- @module src.input.actions

local A = {}

--- Application control: quit the application.
-- @field QUIT string

--- Application control: restart the application.
-- @field RESTART string

--- Application control: reset the camera orientation to default.
-- @field RESET_VIEW string

--- Application control: reset the camera field of view to default.
-- @field RESET_FOV string

--- Application control: toggle the debug overlay (FPS and camera info).
-- @field TOGGLE_DEBUG string

--- Label controls: toggle display of labels.
-- @field TOGGLE_LABELS string

--- Label controls: toggle display of joint markers.
-- @field TOGGLE_JOINTS string

--- Label controls: toggle display of mesh edges.
-- @field TOGGLE_EDGES string

--- Label controls: toggle display of control curves.
-- @field TOGGLE_CURVES string

--- Label controls: toggle display of surface meshes.
-- @field TOGGLE_SURFACES string

--- Shift‐based rotation: rotate the 12‐note map clockwise.
-- @field ROTATE_CW string

--- Shift‐based rotation: rotate the 12‐note map counter‐clockwise.
-- @field ROTATE_CCW string

--- Continuous camera movement: move forward.
-- @field MOVE_FORWARD string

--- Continuous camera movement: move backward.
-- @field MOVE_BACKWARD string

--- Continuous camera movement: strafe left.
-- @field STRAFE_LEFT string

--- Continuous camera movement: strafe right.
-- @field STRAFE_RIGHT string

--- Continuous camera rotation: yaw left.
-- @field ROTATE_LEFT string

--- Continuous camera rotation: yaw right.
-- @field ROTATE_RIGHT string

--- Continuous camera rotation: pitch up.
-- @field PITCH_UP string

--- Continuous camera rotation: pitch down.
-- @field PITCH_DOWN string

--- Zoom control: zoom in.
-- @field ZOOM_IN string

--- Zoom control: zoom out.
-- @field ZOOM_OUT string

--- Lighting control: toggle torus lights.
-- @field TOGGLE_TORUS_LIGHTS string

--- Mode toggle: switch between note‐mode and default.
-- @field TOGGLE_NOTE_MODE string

--- Playback control: toggle MIDI playback on/off.
-- @field TOGGLE_PLAYBACK string

--- Playback control: start song from beginning.
-- @field BEGIN_SONG string

--- Playback control: advance to next song.
-- @field NEXT_SONG string

--- UI interaction: show the extended command popup (triggered by “:”).
-- @field SHOW_COMMAND_MENU string

-- String values for each action
A.QUIT               = "quit"
A.RESTART            = "restart"
A.RESET_VIEW         = "reset_view"
A.RESET_FOV          = "reset_fov"
A.TOGGLE_DEBUG       = "toggle_debug"

A.TOGGLE_LABELS      = "toggle_labels"
A.TOGGLE_JOINTS      = "toggle_joints"
A.TOGGLE_EDGES       = "toggle_edges"
A.TOGGLE_CURVES      = "toggle_curves"
A.TOGGLE_SURFACES    = "toggle_surfaces"

A.ROTATE_CW          = "rotate_cw"
A.ROTATE_CCW         = "rotate_ccw"

A.MOVE_FORWARD       = "move_forward"
A.MOVE_BACKWARD      = "move_backward"
A.STRAFE_LEFT        = "strafe_left"
A.STRAFE_RIGHT       = "strafe_right"

A.ROTATE_LEFT        = "rotate_left"
A.ROTATE_RIGHT       = "rotate_right"
A.PITCH_UP           = "pitch_up"
A.PITCH_DOWN         = "pitch_down"

A.ZOOM_IN            = "zoom_in"
A.ZOOM_OUT           = "zoom_out"

A.TOGGLE_TORUS_LIGHTS = "toggle_torus_lights"

A.TOGGLE_NOTE_MODE   = "toggle_note_mode"

A.TOGGLE_PLAYBACK    = "toggle_playback"
A.BEGIN_SONG         = "play_from_begin"
A.NEXT_SONG          = "move_to_next_song"

A.SHOW_COMMAND_MENU  = "show_command_menu"

return A
