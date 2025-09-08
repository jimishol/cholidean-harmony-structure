-- src/backends/winMidiPort/conf.lua
function love.conf(t)
  t.console        = true       -- show stdout on Windows
  t.window         = nil        -- no graphics window
  t.modules.audio  = false
  t.modules.event  = false
  t.modules.graphics = false
  t.modules.image  = false
  t.modules.joystick = false
  t.modules.keyboard = false
  t.modules.mouse    = false
  t.modules.sound    = false
  -- we only need thread and timer (and ffi inside the thread)
end
