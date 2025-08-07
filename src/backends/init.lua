-- src/backends/init.lua

local M = {}

function M.start(backend)
  local thread_path = nil

  if backend == "fluidsynth" then
    thread_path = "src/backends/fluidsynth/track_active_notes_thread.lua"
  elseif backend == "timidity" then
    thread_path = "src/backends/timidity/track_active_notes_thread.lua"
  elseif backend == "mp3_analysis" then
    thread_path = "src/backends/mp3_analysis/track_active_notes_thread.lua"
  else
    error("Unknown backend: " .. tostring(backend))
  end

  local thread = love.thread.newThread(thread_path)
  thread:start()
end

return M
