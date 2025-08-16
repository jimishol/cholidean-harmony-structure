# Full Keybindings Reference

[← Back to Main README](../README.md)

---

| Key(s)         | Action                  | Description                            |
|----------------|-------------------------|----------------------------------------|
| q              | QUIT                    | Quit the application                   |
| f10            | RESTART                 | Restart the application                |
| space          | RESET_VIEW              | Reset camera orientation toward structure               |
| Ctrl + ↑         | ZOOM_IN          | Narrow (zoom-in) field of view               |
| Ctrl + ↓         | ZOOM_OUT         | Widen (zoom-out) field of view               |
| f              | RESET_FOV               | Reset camera field of view             |
| d              | TOGGLE_DEBUG            | Show/hide debug overlay                |
| Shift + ←      | ROTATE_CW               | Rotate the 12-note map clockwise       |
| Shift + →      | ROTATE_CCW              | Rotate the 12-note map counterclockwise|
| l              | TOGGLE_LABELS           | Show/hide note labels                  |
| j              | TOGGLE_JOINTS           | Show/hide joints                |
| e              | TOGGLE_EDGES            | Show/hide edges                   |
| c              | TOGGLE_CURVES           | Show/hide parametric curve               |
| s              | TOGGLE_SURFACES         | Show/hide surfaces               |
| b              | TOGGLE_TORUS_LIGHTS     | Toggle lights on/off          |
| ←                | ROTATE_LEFT      | Rotate camera yaw left                       |
| →                | ROTATE_RIGHT     | Rotate camera yaw right                      |
| ↑                | PITCH_UP         | Tilt camera up                               |
| ↓                | PITCH_DOWN       | Tilt camera down                             |
| Shift + ↑        | MOVE_FORWARD     | Move camera forward along view direction     |
| Shift + ↓        | MOVE_BACKWARD    | Move camera backward along view direction    |
| h              | TOGGLE_NOTE_MODE        | Toggle mode for instant or delayed note OFF event                       |
| p              | TOGGLE_PLAYBACK         | Play/pause MIDI playback               |
| tab            | BEGIN_SONG              | Start song from beginning              |
| return         | NEXT_SONG               | Advance to next song                   |
| :              | SHOW_COMMAND_MENU       | Pass direct commands to fluidsynth                  |
| a                | SET_TEMPO                | Set tempo in BPM (e.g. `120`)                       |
| b                | SET_SPEED                | Set relative speed (e.g. `0.5` = half speed)        |
| c                | <COMMAND_MENU_C>         | Play through the file once, then repeat it `<count>` more times. `<count>` = `0`cancels loop, `<count> = -1` infinite loop |
| d                | <COMMAND_MENU_D>         | Jump to absolute tick within current MIDI file. The length of a quarter note on 100BPM has 600 ticks.|
| e                | PASS_FLUIDSYNTH_COMMAND  | Send raw commands to FluidSynth shell (In seperate terminal launch fluidsynth and type `help` [Enter] for list of available commands.) |
|-------------------------------------------|---------------------------------------------|-------------------------------------------|
| Hold Right Mouse + Drag              | Rotate view (yaw/pitch)                |                                      |
| Hold Middle Mouse + Drag Up/Down     | Pan camera forward/back along view     |                                      |
| - or +     | Simulate hour of day for background lightning     |                                      |
