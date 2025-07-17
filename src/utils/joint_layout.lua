-- src/utils/joint_layout.lua
local constants = require("constants")

local JointLayout = {}

-- Use torusRadius and torusWidth from constants
local function fx(u)
  return math.sin(u) * (
    constants.torusRadius +
    math.cos(u / 3 + 2 * math.pi) +
    constants.torusWidth * math.cos(u / 3 - math.pi)
  )
end

local function fy(u)
  return math.cos(u) * (
    constants.torusRadius +
    math.cos(u / 3 + 2 * math.pi) +
    constants.torusWidth * math.cos(u / 3 - math.pi)
  )
end

local function fz(u)
  return math.sin(u / 3 + 2 * math.pi) +
         constants.torusWidth * math.sin(u / 3 - math.pi)
end

--- Returns a table of 12 joint positions indexed by ID (0–11)
function JointLayout.getJointPositions()
  local jointPos = {}
  local step = 2 * math.pi / 12  -- 12-tone circle

  for i = 0, 11 do
    local u = i * step
    jointPos[i] = { fx(u), fy(u), fz(u) }
  end

  return jointPos
end

return JointLayout
