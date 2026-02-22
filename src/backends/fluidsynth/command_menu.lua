--- Fluidsynth backend in-game command menu.
-- Presents a simple overlay for selecting and sending MIDI control messages
-- (tempo, speed, loop, seek, raw) and a scrollable help dump.
-- Expects a file `fluidsynth_help.txt` alongside this module.
-- @module src.backends.fluidsynth.command_menu

local CommandMenu = {}
CommandMenu.__index = CommandMenu

--- Key-to-command mapping for numeric input modes.
-- @table topics
-- @field a "player_tempo_bpm"
-- @field b "player_tempo_int"
-- @field c "player_loop"
-- @field d "player_seek"
local topics = {
  a = "player_tempo_bpm",
  b = "player_tempo_int",
  c = "player_loop",
  d = "player_seek",
}

-- Load static FluidSynth help text once
local helpLines = {}
do
  local raw = love.filesystem.read("src/backends/fluidsynth/fluidsynth_help.txt") or ""
  for line in raw:gmatch("[^\r\n]+") do
    table.insert(helpLines, line)
  end
end

--- Create a new command menu instance.
-- @constructor
-- @treturn CommandMenu
function CommandMenu:new()
  return setmetatable({
    visible    = false,    -- whether the menu is drawn
    state      = "select", -- "select", "input" or "help"
    cmdKey     = nil,      -- selected key ("a"–"e" or "h")
    text       = "",       -- accumulated text in input mode
    _skipFirst = false,    -- skip first char after pressing "e"
    scrollLine = 1,        -- first visible help line
  }, self)
end

--- Toggle menu visibility and reset when hiding.
function CommandMenu:toggle()
  self.visible = not self.visible
  if not self.visible then
    self.state, self.cmdKey, self.text, self._skipFirst, self.scrollLine =
      "select", nil, "", false, 1
  end
end

--- Handle key presses.
-- Returns a command string on Enter; nil otherwise.
function CommandMenu:keypressed(key)
  if not self.visible then
    return
  end

  -- HELP MODE: only Esc to exit
  if self.state == "help" then
    if key == "escape" then
      self.state = "select"
    end
    return
  end

  -- SELECT MODE
  if self.state == "select" then
    if key == "escape" then
      self:toggle()
      return
    end

    -- open help
    if key == "h" then
      self.state      = "help"
      self.scrollLine = 1
      return
    end

    -- raw mode
    if key == "e" then
      self.cmdKey     = "e"
      self.state      = "input"
      self.text       = ""
      self._skipFirst = true
      return
    end

    -- numeric modes
    local letter = key:match("^([a-d])$")
    if letter then
      self.cmdKey = letter
      self.state  = "input"
      self.text   = ""
    end

    return
  end

  -- INPUT MODE
  if key == "backspace" then
    self.text = self.text:sub(1, -2)

  elseif key == "escape" then
    self.state, self.cmdKey, self.text = "select", nil, ""
    return

  elseif key == "return" then
    local out
    if self.cmdKey == "e" then
      out = self.text
    else
      local topic = topics[self.cmdKey]
      local n     = tonumber(self.text)
      out = topic
      if n then out = out .. " " .. n end
    end

    self:toggle()
    print("DEBUG: sending ->", out)
    return out
  end
end

--- Collect text input in input mode.
function CommandMenu:textinput(t)
  if not self.visible or self.state ~= "input" then
    return
  end

  if self.cmdKey == "e" and self._skipFirst then
    self._skipFirst = false
    return
  end

  if self.cmdKey == "e" then
    self.text = self.text .. t
    return
  end

  if t == "-" and self.text == "" then
    self.text = "-"
    return
  end

  if t:match("[0-9.]") then
    if t == "." and self.text:find("%.") then return end
    self.text = self.text .. t
  end
end

--- Handle mouse wheel for scrolling help.
-- @tparam number dx horizontal scroll (ignored)
-- @tparam number dy vertical scroll (positive = up)
function CommandMenu:wheelmoved(dx, dy)
  if not self.visible or self.state ~= "help" then return end

  -- scroll 2 lines per wheel notch
  self.scrollLine = self.scrollLine - dy * 2
  self.scrollLine = math.max(1, math.min(self.scrollLine, #helpLines))
end

--- Draw the menu or help overlay.
-- @tparam number x X-coordinate (default 50)
-- @tparam number y Y-coordinate (default 50)
function CommandMenu:draw(x, y)
  if not self.visible then return end
  x = x or 50
  y = y or 50

  local font  = love.graphics.getFont()
  local lineH = font:getHeight()
  local winH  = love.graphics.getHeight()

  -- HELP OVERLAY: single column, scrollable
  if self.state == "help" then
    love.graphics.setColor(1, 1, 1)
    local maxLines = math.floor((winH - y - 40) / lineH)
    for i = 0, maxLines - 1 do
      local idx = self.scrollLine + i
      if idx > #helpLines then break end
      love.graphics.print(helpLines[idx], x, y + i * lineH)
    end

    love.graphics.printf(
      "[Esc] Back    Mouse Wheel to Scroll",
      x,
      winH - 30,
      love.graphics.getWidth() - 2 * x,
      "left"
    )
    return
  end

  -- NORMAL MENU DRAW
  local label = "[a]tempo(bpm) [b]speed(x1) [c]loop [d]seek [h]help [e]raw"
  if self.state == "input" then
    label = self.cmdKey .. ": " .. self.text .. "_"
  end
  local hint = "(a–d numeric, h help, e raw, Enter to send, Esc to cancel)"
  local w    = math.max(font:getWidth(label), font:getWidth(hint)) + 16
  local hgt  = font:getHeight() * 2 + 16

  love.graphics.setColor(0, 0, 0, 0.2)
  love.graphics.rectangle("fill", x, y, w, hgt, 4, 4)
  love.graphics.setColor(0.7, 0.7, 0.7)
  love.graphics.print(hint, x + 8, y + 8)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(label, x + 8, y + 8 + font:getHeight() * 1.2)
end

return CommandMenu
