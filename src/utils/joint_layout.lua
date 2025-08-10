--- JointLayout module for computing joint positions on a torus and billboard yaw.
-- @module JointLayout

local JointLayout = {}

--- Major radius of the torus.
-- @tfield number torusRadius
local torusRadius = 7

--- Minor radius (tube width) of the torus.
-- @tfield number torusWidth
local torusWidth = 3

--- Compute the x-coordinate on the torus for a given parameter.
-- @local
-- @tparam number u Parameter normalized from 0 to 1
-- @treturn number x-coordinate
local function x(u)
  local a = u * math.pi / 2
  local b = u * math.pi / 6
  return math.sin(a) * (
    torusRadius
    + math.cos(b + 2 * math.pi)
    + torusWidth * math.cos(b - math.pi)
  )
end

--- Compute the y-coordinate on the torus for a given parameter.
-- @local
-- @tparam number u Parameter normalized from 0 to 1
-- @treturn number y-coordinate
local function y(u)
  local a = u * math.pi / 2
  local b = u * math.pi / 6
  return math.cos(a) * (
    torusRadius
    + math.cos(b + 2 * math.pi)
    + torusWidth * math.cos(b - math.pi)
  )
end

--- Compute the z-coordinate on the torus for a given parameter.
-- @local
-- @tparam number u Parameter normalized from 0 to 1
-- @treturn number z-coordinate
local function z(u)
  local b = u * math.pi / 6
  return math.sin(b + 2 * math.pi)
    + torusWidth * math.sin(b - math.pi)
end

--- Returns all joint positions on the torus.
-- Generates 12 points indexed 0 through 11.
-- @treturn table<number, {number, number, number}> Map from joint index to {x, y, z}.
function JointLayout.getJointPositions()
  local jointPos = {}
  for i = 0, 11 do
    jointPos[i] = {
      -y(i + 8),
       z(i + 8),
      -x(i + 8)
    }
  end
  return jointPos
end

--- Computes centers of four triangles defined by joint indices.
-- Triangles use joints (0,8,4), (1,9,5), (2,10,6), and (3,11,7).
-- @treturn table<number, {number, number, number}> List of triangle center coordinates.
function JointLayout.getTriangleCenters()
  local jointPos = JointLayout.getJointPositions()

  --- Compute centroid of three joint positions.
  -- @local
  -- @tparam number a First joint index
  -- @tparam number b Second joint index
  -- @tparam number c Third joint index
  -- @treturn {number, number, number} Centroid {x, y, z}
  local function center(a, b, c)
    local A, B, C = jointPos[a], jointPos[b], jointPos[c]
    return {
      (A[1] + B[1] + C[1]) / 3,
      (A[2] + B[2] + C[2]) / 3,
      (A[3] + B[3] + C[3]) / 3
    }
  end

  return {
    center(0,  8,  4),
    center(1,  9,  5),
    center(2, 10,  6),
    center(3, 11,  7)
  }
end

--- Computes the world-Y yaw angle for a billboard to face the camera.
-- @tparam table labelPos   Three-element array {x, y, z} position of the label
-- @tparam table cameraPos  Table with fields x, y, z for the camera position
-- @treturn number          Yaw angle in radians around the world-Y axis
function JointLayout.getBillboardYaw(labelPos, cameraPos)
  local dx = cameraPos.x - labelPos[1]
  local dz = cameraPos.z - labelPos[3]
  return math.atan(dx, dz)
end

return JointLayout
