-- src/backends/fluidsynth/command_menu.lua

local CommandMenu = {}
CommandMenu.__index = CommandMenu

-- map keys a–d to FluidSynth topics
local topics = {
  a = "player_tempo_bpm",
  b = "player_tempo_int",
  c = "player_loop",
  d = "player_seek",
}

function CommandMenu:new()
  -- initial hidden + select state
  return setmetatable({
    visible = false,
    state   = "select", -- or "input"
    cmdKey  = nil,      -- one of "a","b","c","d","e"
    text    = "",       -- accumulated input
  }, self)
end

-- toggle menu visibility; reset on hide
function CommandMenu:toggle()
  self.visible = not self.visible
  if not self.visible then
    self.state, self.cmdKey, self.text = "select", nil, ""
  end
end

-- handle key presses
function CommandMenu:keypressed(key)
  if not self.visible then
    return
  end

  -- SELECT MODE
  if self.state == "select" then
    -- escape: hide menu
    if key == "escape" then
      self:toggle()
      return
    end

    -- raw ([e]) goes into input
    if key == "e" then
      self.cmdKey = "e"
      self.state  = "input"
      self.text   = ""
      self._skipFirst = true
      return
    end

    -- numeric (a–d) goes into input
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
    -- remove last char
    self.text = self.text:sub(1, -2)

  elseif key == "escape" then
    -- cancel input, back to select
    self.state, self.cmdKey, self.text = "select", nil, ""
    return

  elseif key == "return" then
    -- build message
    local out
    if self.cmdKey == "e" then
      -- raw: exactly what typed
      out = self.text

    else
      -- numeric: prepend topic + optional number
      local topic = topics[self.cmdKey]
      local n     = tonumber(self.text)
      out = topic
      if n then out = out .. " " .. n end
    end

    -- auto-hide + reset
    self:toggle()
    print("DEBUG: sending ->", out)  -- for tracing
    return out
  end
end

-- collect text chars
function CommandMenu:textinput(t)
  if not self.visible or self.state ~= "input" then
    return
  end
  -- swallow that initial ‘e’
  if self.cmdKey == "e" and self._skipFirst then
    self._skipFirst = false
    return
  end
  if self.cmdKey == "e" then
    self.text = self.text .. t
    return
  end

  -- numeric input: only -, digits, one dot
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

-- draw menu
function CommandMenu:draw(x, y)
  if not self.visible then return end
  x, y = x or 50, y or 50
  local font = love.graphics.getFont()

  local label = (self.state == "select")
    and "[a]tempo(bpm) [b]speed(x1) [c]loop [d]seek [e]raw"
    or  self.cmdKey .. ": " .. self.text .. "_"
  local hint  = "(a–d numeric, e raw, Enter to send, Esc to cancel)"
  local w     = math.max(font:getWidth(label), font:getWidth(hint)) + 16
  local h     = font:getHeight() * 2 + 16

  love.graphics.setColor(0,0,0,0.2)
  love.graphics.rectangle("fill", x, y, w, h, 4,4)
  love.graphics.setColor(0.7,0.7,0.7)
  love.graphics.print(hint, x+8, y+8)
  love.graphics.setColor(1,1,1)
  love.graphics.print(label, x+8, y+8 + font:getHeight()*1.2)
end

return CommandMenu
