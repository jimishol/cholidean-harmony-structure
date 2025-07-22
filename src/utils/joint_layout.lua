local JointLayout = {}

local torusRadius = 7
local torusWidth = 3

-- Core parametric functions
local function x(u)
  local a = u * math.pi / 2          -- degrees
  local b = u * math.pi / 6          -- degrees
  return math.sin(a) * (
    torusRadius + math.cos(b + 2 * math.pi) + torusWidth * math.cos(b - math.pi)
  )
end

local function y(u)
  local a = u * math.pi / 2
  local b = u * math.pi / 6
  return math.cos(a) * (
    torusRadius + math.cos(b + 2 * math.pi) + torusWidth * math.cos(b - math.pi)
  )
end

local function z(u)
  local b = u * math.pi / 6
  return math.sin(b + 2 * math.pi) + torusWidth * math.sin(b - math.pi)
end

function JointLayout.getJointPositions()
  local jointPos = {}
  for i = 0, 11 do
    jointPos[i] = {
      -y(i+8),
      z(i+8),
      -x(i+8)
    }
  end

  return jointPos
end

function JointLayout.getTriangleCenters()
  local jointPos = JointLayout.getJointPositions()

  local function center(a, b, c)
    local A, B, C = jointPos[a], jointPos[b], jointPos[c]
    return {
      (A[1] + B[1] + C[1]) / 3,
      (A[2] + B[2] + C[2]) / 3,
      (A[3] + B[3] + C[3]) / 3
    }
  end

  return {
    center(0, 8, 4),
    center(1, 9, 5),
    center(2, 10, 6),
    center(3, 11, 7)
  }
end

--- Compute Euler rotation angles from joint to camera
-- Returns yaw (Y), pitch (X), roll (Z)
function JointLayout.getRotationToCamera(jointPos, cameraPos)
  local dx = cameraPos.x - jointPos[1]
  local dy = cameraPos.y - jointPos[2]
  local dz = cameraPos.z - jointPos[3]

  -- Compute Yaw (around Y axis — horizontal turn)
  local yaw = math.atan(dx, -dz)

  -- Compute Pitch (around X axis — vertical tilt)
  local horizDist = math.sqrt(dx*dx + dz*dz)
  local pitch = math.atan(dy, horizDist)

  -- Roll is optional — only needed if labels bank or spin
  local roll = 0  -- keep neutral unless you need artistic twist

  return { x = pitch, y = yaw, z = roll }
end

return JointLayout
