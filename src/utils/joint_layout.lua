local JointLayout = {}

-- Geometric constants (as used in SoFourths)
local torusRadius = 7
local torusWidth = 3

-- Degree conversion
local function deg(a)
  return a * math.pi / 180
end

-- Parametric spiral functions matching your structure
local function x(u)
  local a = u * 90
  local b = u * 30
  return math.sin(deg(a)) * (
    torusRadius + math.cos(deg(b + 360)) + torusWidth * math.cos(deg(b - 180))
  )
end

local function y(u)
  local a = u * 90
  local b = u * 30
  return math.cos(deg(a)) * (
    torusRadius + math.cos(deg(b + 360)) + torusWidth * math.cos(deg(b - 180))
  )
end

local function z(u)
  local b = u * 30
  return math.sin(deg(b + 360)) + torusWidth * math.sin(deg(b - 180))
end

--- Returns a table of 12 joint positions indexed by ID (0–11)
function JointLayout.getJointPositions()
  local jointPos = {}
  for i = 0, 11 do
    local u = i - 1.5  -- aligns sampling with hardcoded spiral layout
    jointPos[i] = {
      x(u),
      y(u),
     -z(u)  -- 3DreamEngine axis adjustment (Z is flipped)
    }
  end
  return jointPos
end

--- Returns triangle centers for augmented third triads
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
