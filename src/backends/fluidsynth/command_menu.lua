--- Fluidsynth backend in‐game command menu.
-- Presents a simple overlay for selecting and sending MIDI control messages
-- (tempo, speed, loop, seek, or raw) to a Fluidsynth server.
-- @module src.backends.fluidsynth.command_menu

local CommandMenu = {}
CommandMenu.__index = CommandMenu

--- Key-to-command mapping for numeric input modes.
-- Maps single letters a–d to Fluidsynth command topics.
-- @local
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

--- Create a new command menu instance.
-- Initially hidden and in select mode.
-- @constructor
-- @treturn CommandMenu New menu object
function CommandMenu:new()
  return setmetatable({
    visible    = false,  -- whether the menu is drawn
    state      = "select", -- "select" or "input"
    cmdKey     = nil,    -- selected key ("a"–"e")
    text       = "",     -- accumulated text in input mode
    _skipFirst = false,  -- internals: skip first character after raw key
  }, self)
end

--- Toggle visibility of the menu.
-- When hiding, resets state back to select and clears text.
function CommandMenu:toggle()
  self.visible = not self.visible
  if not self.visible then
    self.state, self.cmdKey, self.text, self._skipFirst =
      "select", nil, "", false
  end
end

--- Handle a key press event.
-- In select mode, chooses a command or exits.
-- In input mode, edits the text buffer or submits the command.
-- @tparam string key The key that was pressed
-- @treturn[string][nil] On Enter, returns the built command string; otherwise nil
function CommandMenu:keypressed(key)
  if not self.visible then
    return
  end

  if self.state == "select" then
    if key == "escape" then
      self:toggle()
      return
    end

    if key == "e" then
      self.cmdKey     = "e"
      self.state      = "input"
      self.text       = ""
      self._skipFirst = true
      return
    end

    local letter = key:match("^([a-d])$")
    if letter then
      self.cmdKey = letter
      self.state  = "input"
      self.text   = ""
      return
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
-- Allows only valid numeric characters for a–d modes,
-- and arbitrary text for raw mode.
-- @tparam string t The text input (single character)
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
    if t == "." and self.text:find("%.") then
      return
    end
    self.text = self.text .. t
  end
end

--- Draw the command menu overlay.
-- Renders a semi-transparent background and the current menu text.
-- @tparam number x X-coordinate to start drawing (default 50)
-- @tparam number y Y-coordinate to start drawing (default 50)
function CommandMenu:draw(x, y)
  if not self.visible then
    return
  end
  x = x or 50
  y = y or 50

  local font  = love.graphics.getFont()
  local label = (self.state == "select")
    and "[a]tempo(bpm) [b]speed(x1) [c]loop [d]seek [e]raw"
    or  (self.cmdKey .. ": " .. self.text .. "_")
  local hint  = "(a–d numeric, e raw, Enter to send, Esc to cancel)"
  local w     = math.max(font:getWidth(label), font:getWidth(hint)) + 16
  local h     = font:getHeight() * 2 + 16

  love.graphics.setColor(0, 0, 0, 0.2)
  love.graphics.rectangle("fill", x, y, w, h, 4, 4)
  love.graphics.setColor(0.7, 0.7, 0.7)
  love.graphics.print(hint, x + 8, y + 8)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(label, x + 8, y + 8 + font:getHeight() * 1.2)
end

return CommandMenu
