local constants = require("constants")

local JointLayout = {}

-- Parametric torus functions
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
  local step = 2 * math.pi / 12

  for i = 0, 11 do
    local u = i * step
    jointPos[i] = { -fy(u), fx(u), fz(u) }
  end

  return jointPos
end

--- Returns a table of 4 triangle centers for augmented third triads
function JointLayout.getTriangleCenters()
  local jointPos = JointLayout.getJointPositions()

  local function center(a, b, c)
    local A, B, C = jointPos[a], jointPos[b], jointPos[c]
    return {
      (A[1] + B[1] + C[1]) / 3,
      (A[2] + B[2] + C[2]) / 3,
      (A[3] + B[3] + C[3]) / 3,
    }
  end

  return {
    center(0, 8, 4),
    center(1, 9, 5),
    center(2, 10, 6),
    center(3, 11, 7),
  }
end

return JointLayout
