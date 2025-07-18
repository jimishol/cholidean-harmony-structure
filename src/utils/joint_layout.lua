-- JointLayout using hard-coded Blender origins mapped to 3DreamEngine space
local JointLayout = {}

--- Returns a table of 12 joint positions indexed by ID (0–11)
function JointLayout.getJointPositions()
  local jointPos = {
    [0]  = { -8.000000, 1.732000, -0.000000 },
    [1]  = {  0.000000, 2.000000, -7.000000 },
    [2]  = {  6.000000, 1.732000, -0.000000 },
    [3]  = {  0.000000, 1.000000,  5.268000 },
    [4]  = { -5.000000, 0.000000, -0.000000 },
    [5]  = {  0.000000, -1.000000, -5.268000 },
    [6]  = {  6.000000, -1.732000, -0.000000 },
    [7]  = {  0.000000, -2.000000,  7.000000 },
    [8]  = { -8.000000, -1.732000, -0.000000 },
    [9]  = {  0.000000, -1.000000, -8.732000 },
    [10] = {  9.000000, 0.000000, -0.000000 },
    [11] = {  0.000000, 1.000000,  8.732000 },
  }
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
