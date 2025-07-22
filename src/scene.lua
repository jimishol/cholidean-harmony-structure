-- src/scene.lua

local lfs           = love.filesystem
local skyExt        = require("extensions/sky")
local constants     = require("constants")
local daycycle      = require("utils.daycycle")
local JointLayout   = require("src.utils.joint_layout")
local NoteSystem    = require("src.systems.note_system")
local camera        = require("camera")
local A             = require("src.input.actions")

local scene = {
  joints       = {},
  edges        = {},
  curves       = {},
  surfaces     = {},
  labels       = {},   -- raw .obj label meshes
  labelModels  = {},   -- map name → mesh
  activeLabels = {},   -- per-frame { name, color, position, isTonic }
}

-- Visibility toggles
local showJoints, showEdges, showCurves, showSurfaces = true, true, true, true
local showLabels   = true
local showDebug = false

-- Time & lighting
local dayTime = constants.day_night
local hdrImg  = love.graphics.newImage(constants.bck_image)
local sun

-- Helper: load all .obj from assets/models/<folder> into `out`
local function loadCategory(folder, out, dream)
  local base = "assets/models/" .. folder .. "/"
  for _, file in ipairs(lfs.getDirectoryItems(base)) do
    if file:match("%.obj$") then
      local name = file:match("(.+)%.obj")
      local ok, obj = pcall(function() return dream:loadObject(base .. name) end)
      if ok and obj then
        obj.id = name
        table.insert(out, obj)
      else
        print("⚠️ Failed to load " .. folder .. ": " .. name)
      end
    end
  end
end

function scene.load(dream)
  -- Setup sun & day/night cycle
  sun = dream:newLight("sun")
  sun:addNewShadow()
  sun:setBrightness((daycycle.computeDaycycle(dayTime)))

  -- Load geometry categories
  loadCategory("joints",   scene.joints,   dream)
  loadCategory("edges",    scene.edges,    dream)
  loadCategory("curves",   scene.curves,   dream)
  loadCategory("surfaces", scene.surfaces, dream)
  loadCategory("labels",   scene.labels,   dream)

  -- Build fast label lookup
  for _, mesh in ipairs(scene.labels) do
    scene.labelModels[mesh.id] = mesh
  end

  -- Initialize note system & labels
  scene.noteSystem = NoteSystem:new(scene)
  scene.updateLabels()
  scene.dayTime = dayTime
end

function scene.update(dt)
  -- Adjust dayTime via +/- keys
  if love.keyboard.isDown("+", "=") then
    dayTime = dayTime + constants.day_night_speed
    scene.dayTime = dayTime % 24
  elseif love.keyboard.isDown("-") then
    dayTime = dayTime - constants.day_night_speed
    scene.dayTime = dayTime % 24
  end
end

function scene.draw(dream)
  -- Sky & lighting
  dream:addLight(sun)
  local sunF, envB = daycycle.computeDaycycle(dayTime)
  skyExt:setDaytime(sun, sunF)
  dream:setSky(hdrImg, envB)

  -- Draw geometry
  if showJoints   then for _, o in ipairs(scene.joints)   do dream:draw(o) end end
  if showEdges    then for _, o in ipairs(scene.edges)    do dream:draw(o) end end
  if showCurves   then for _, o in ipairs(scene.curves)   do dream:draw(o) end end
  if showSurfaces then for _, o in ipairs(scene.surfaces) do dream:draw(o) end end

  if showLabels then
    for i, lbl in ipairs(scene.activeLabels) do
      -- look up the mesh by name, or fall back to the i-th label
      local mesh = scene.labelModels[lbl.name] or scene.labels[i]
      if not mesh then
        print(("No label mesh for %s"):format(lbl.name))
      else
        -- build transform: translate out to `pos`, then scale small
       local x, y, z = table.unpack(lbl.position)
       local transform = dream.mat4.getTranslate(x, y, z)

	    -- Optional: rotate label to face camera
	    if constants.dynamicLabelFacing then
	      -- use joint position (J) instead of label, for performance
	      local J = JointLayout.getJointPositions()[i - 1]  -- same index as label
	      local cameraPos = camera.View.Pos

	      -- compute full rotation: pitch (X), yaw (Y), roll (Z)
	      local rot = JointLayout.getRotationToCamera(J, cameraPos)

	      -- apply all three rotations in order: pitch → yaw → roll
	      transform = transform
		* dream.mat4.getRotateX(rot.x)
		* dream.mat4.getRotateY(rot.y)
		* dream.mat4.getRotateZ(rot.z)
	    end

       transform = transform * dream.mat4.getScale(1)
       -- draw exactly like your joints/edges/etc.
       dream:draw(mesh, transform)
      end
    end
  end

end

function scene.updateLabels()
  local jointPos        = JointLayout.getJointPositions()
  local triangleCenters = JointLayout.getTriangleCenters()
  local dist            = constants.label_distance

  scene.activeLabels = {}
  for idx = 0, 11 do
    local noteInfo = scene.noteSystem.notes[idx+1]
    local J = jointPos[idx]
    local C = triangleCenters[(idx % #triangleCenters) + 1]

    -- your exact placement formula
    local pos = {
      C[1] + (J[1] - C[1]) * dist,
      C[2] + (J[2] - C[2]) * dist,
      C[3] + (J[3] - C[3]) * dist,
    }

    scene.activeLabels[#scene.activeLabels+1] = {
      name     = noteInfo.name,
      color    = constants.COLOR_MAP[noteInfo.name] or {1,1,1},
      position = pos,
    }
  end
end

function scene.pressedAction(action)
  -- Rotate the 12-tone map
  if action == A.ROTATE_CW then
    scene.noteSystem:shift(1);   scene.updateLabels(); return true
  elseif action == A.ROTATE_CCW then
    scene.noteSystem:shift(-1);  scene.updateLabels(); return true
  end

  -- Geometry toggles
  if action == A.TOGGLE_JOINTS   then showJoints   = not showJoints   ; return true end
  if action == A.TOGGLE_EDGES    then showEdges    = not showEdges    ; return true end
  if action == A.TOGGLE_CURVES   then showCurves   = not showCurves   ; return true end
  if action == A.TOGGLE_SURFACES then showSurfaces = not showSurfaces ; return true end

  -- Label toggle (L key)
  if action == A.TOGGLE_LABELS then
    showLabels = not showLabels
    return true
  end

  if action == A.TOGGLE_DEBUG then
    showDebug = not showDebug
    return true
  end

  return false
end

function scene.apply()
  if not showDebug then return end
    local pos = camera.View.Pos
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    love.graphics.print("Day time: " .. daycycle.formatTime(scene.dayTime), 10, 40)
    love.graphics.print(string.format("Camera Pos: (%.2f, %.2f, %.2f)", pos.x, pos.y, pos.z), 10, 60)
end

return scene
