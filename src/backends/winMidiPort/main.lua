-- src/backends/winMidiPort/main.lua
-- Headless tester for your winMidiPort track_active_notes_thread.lua

-- grab the three channels that the thread uses:
local quitChan      = love.thread.getChannel("quit")
local notesChannel  = love.thread.getChannel("active_notes")
local midiPortChan  = love.thread.getChannel("midiPort")

-- 1) tell the thread which port to open (e.g. "14:0" or whatever your device is)
midiPortChan:push("14:0")

-- 2) spawn the active-notes tracker thread
local thread = love.thread.newThread("track_active_notes_thread.lua")
thread:start()
print("[main] spawned track_active_notes_thread.lua")

-- simple stopwatch so we auto-quit after 10 seconds
local elapsed = 0

function love.update(dt)
  elapsed = elapsed + dt

  -- pull any new “active notes” table from the thread
  local notes = notesChannel:pop()
  if notes then
    print("→ Active notes:", table.concat(notes, ", "))
  end

  -- after 10 s, tell the thread to quit and shut down Love
  if elapsed > 10 then
    print("[main] sending quit and closing")
    quitChan:push("quit")
    os.exit()
  end
end

function love.draw()
  -- no-op, we’re headless
end
