--- JointLayout helper for toroidal joint placement and billboarding.
-- Computes 12 joint positions on a torus, four triangle centroids,
-- and the yaw angle needed to billboard a label toward the camera.
-- @module src.utils.joint_layout

local JointLayout = {}

--- Major radius of the torus.
-- Distance from the tube’s center to the torus center.
-- @local
-- @number torusRadius
local torusRadius = 7

--- Minor radius (tube width) of the torus.
-- Radius of the circular cross‐section.
-- @local
-- @number torusWidth
local torusWidth = 3

--- Compute the x‐coordinate on the torus for a parameter u.
-- @local
-- @tparam number u Parameter normalized [0..1]
-- @treturn number x‐coordinate
local function x(u)
  local a = u * math.pi / 2
  local b = u * math.pi / 6
  return math.sin(a) * (
    torusRadius
    + math.cos(b + 2 * math.pi)
    + torusWidth * math.cos(b - math.pi)
  )
end

--- Compute the y‐coordinate on the torus for a parameter u.
-- @local
-- @tparam number u Parameter normalized [0..1]
-- @treturn number y‐coordinate
local function y(u)
  local a = u * math.pi / 2
  local b = u * math.pi / 6
  return math.cos(a) * (
    torusRadius
    + math.cos(b + 2 * math.pi)
    + torusWidth * math.cos(b - math.pi)
  )
end

--- Compute the z‐coordinate on the torus for a parameter u.
-- @local
-- @tparam number u Parameter normalized [0..1]
-- @treturn number z‐coordinate
local function z(u)
  local b = u * math.pi / 6
  return math.sin(b + 2 * math.pi)
    + torusWidth * math.sin(b - math.pi)
end

--- Get positions of all 12 joints on the torus.
-- Joints are indexed 0–11 around the torus circle.
-- @treturn table<number, {number,number,number}>  
--   Map from joint index → 3‐element position array {x, y, z}
function JointLayout.getJointPositions()
  local jointPos = {}
  for i = 0, 11 do
    jointPos[i] = {
      -y(i + 8),
       z(i + 8),
      -x(i + 8),
    }
  end
  return jointPos
end

--- Get centroids of four triangular faces on the torus.
-- Triangles defined by joint triplets (0,8,4), (1,9,5), (2,10,6), (3,11,7).
-- @treturn table<number, {number,number,number}>  
--   Array of 4 centroids, each a 3‐element {x, y, z} array
function JointLayout.getTriangleCenters()
  local jointPos = JointLayout.getJointPositions()

  --- Compute centroid of three joint positions.
  -- @local
  -- @tparam number a Index of first joint
  -- @tparam number b Index of second joint
  -- @tparam number c Index of third joint
  -- @treturn {number,number,number} Centroid {x, y, z}
  local function center(a, b, c)
    local A, B, C = jointPos[a], jointPos[b], jointPos[c]
    return {
      (A[1] + B[1] + C[1]) / 3,
      (A[2] + B[2] + C[2]) / 3,
      (A[3] + B[3] + C[3]) / 3,
    }
  end

  return {
    center(0,  8,  4),
    center(1,  9,  5),
    center(2, 10,  6),
    center(3, 11,  7),
  }
end

--- Compute world-Y yaw angle for a billboard to face the camera.
-- @tparam {number,number,number} labelPos  3-element array {x, y, z}
-- @tparam table               cameraPos  Table with fields `x`, `y`, `z`
-- @treturn number  Yaw angle in radians around the world-Y axis
function JointLayout.getBillboardYaw(labelPos, cameraPos)
  local dx = cameraPos.x - labelPos[1]
  local dz = cameraPos.z - labelPos[3]
  return math.atan(dx, dz)
end

return JointLayout
