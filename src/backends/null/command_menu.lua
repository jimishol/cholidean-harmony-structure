--- Null backend in‐game command menu.
-- Provides a minimal select‐and‐input overlay for manual control
-- when no real backend is attached.
-- @module src.backends.null.command_menu

local CommandMenu = {}
CommandMenu.__index = CommandMenu

--- Key‐to‐command mapping for numeric input modes.
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

--- Create a new CommandMenu instance.
-- Initially hidden and in select mode.
-- @constructor
-- @treturn CommandMenu New command‐menu object
function CommandMenu:new()
  return setmetatable({
    visible = false,  -- whether the menu is shown
    state   = "select", -- "select" or "input"
    cmdKey  = nil,    -- selected key ("a"–"d")
    text    = "",     -- accumulated input text
  }, self)
end

--- Toggle menu visibility.
-- When hiding, resets to select mode and clears any input.
function CommandMenu:toggle()
  self.visible = not self.visible
  if not self.visible then
    self.state, self.cmdKey, self.text = "select", nil, ""
  end
end

--- Handle a key press event.
-- In select mode, chooses a command key or exits.
-- In input mode, edits buffer or submits the command.
-- @tparam string key The key that was pressed
-- @treturn[string][nil] The message to send when Enter is pressed; otherwise nil
function CommandMenu:keypressed(key)
  if not self.visible then return end

  if self.state == "select" then
    if key == "escape" then
      self:toggle()
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

  -- INPUT mode
  if key == "backspace" then
    self.text = self.text:sub(1, -2)

  elseif key == "escape" then
    -- cancel input, return to select mode
    self.state, self.cmdKey, self.text = "select", nil, ""
    return

  elseif key == "return" then
    local value = tonumber(self.text)
    local topic = topics[self.cmdKey]
    self:toggle()
    local message = topic
    if value then
      message = message .. " " .. value
    end
    return message
  end
end

--- Collect text input in input mode.
-- Allows only valid numeric characters (digits, dot, leading minus).
-- @tparam string t The character input
function CommandMenu:textinput(t)
  if not self.visible or self.state ~= "input" then return end

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
-- Renders a semi‐transparent background and the current prompt.
-- @tparam number[opt] x X coordinate (default 50)
-- @tparam number[opt] y Y coordinate (default 50)
function CommandMenu:draw(x, y)
  if not self.visible then return end
  x, y = x or 50, y or 50
  local font = love.graphics.getFont()

  local prompt = (self.state == "select")
    and "[a]tempo(bpm) [b]speed(x1) [c]loop [d]seek"
    or  (self.cmdKey .. ": " .. self.text .. "_")
  local hint = "(press a–d, type number, Enter to send)"
  local w    = math.max(font:getWidth(prompt), font:getWidth(hint)) + 16
  local h    = font:getHeight() * 2 + 16

  love.graphics.setColor(0, 0, 0, 0.2)
  love.graphics.rectangle("fill", x, y, w, h, 4, 4)
  love.graphics.setColor(0.7, 0.7, 0.7)
  love.graphics.print(hint, x + 8, y + 8)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(prompt, x + 8, y + 8 + font:getHeight() * 1.2)
end

return CommandMenu
