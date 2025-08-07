-- src/midi/command_menu.lua

local CommandMenu = {}
CommandMenu.__index = CommandMenu

local topics = {
  a = "player_tempo_bpm",
  b = "player_tempo_int",
  c = "player_loop",
  d = "player_seek",
}

function CommandMenu:new()
  return setmetatable({
    visible = false,
    state   = "select",
    cmdKey  = nil,
    text    = "",
  }, self)
end

function CommandMenu:toggle()
  self.visible = not self.visible
  if not self.visible then
    self.state, self.cmdKey, self.text = "select", nil, ""
  end
end

function CommandMenu:keypressed(key)
  if not self.visible then
    return
  end

  if self.state == "select" then
    local letter = key:match("^([a-d])$")
    if letter then
      self.cmdKey = letter
      self.state  = "input"
      self.text   = ""
      return
    elseif key == "escape" then
      self:toggle()
      return
    end
    return
  end

  -- INPUT state
  if key == "backspace" then
    self.text = self.text:sub(1, -2)
  elseif key == "escape" then
    -- go back to select mode, but don't hide
    self:toggle()
    return

  elseif key == "return" then
    local value = tonumber(self.text)
    local topic = topics[self.cmdKey]
    self:toggle()
    local message = topic
    if value then message = message .. " " .. value end
    return message
  end
end

function CommandMenu:textinput(t)
  if not self.visible or self.state ~= "input" then
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

function CommandMenu:draw(x, y)
  if not self.visible then return end
  x, y = x or 50, y or 50
  local font = love.graphics.getFont()

  local prompt = (self.state == "select")
    and "[a]tempo(bpm) [b]speed(x1) [c]loop [d]seek"
    or  self.cmdKey .. ": " .. self.text .. "_"

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
