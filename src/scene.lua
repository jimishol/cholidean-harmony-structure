-- src/scene.lua

local lfs         = love.filesystem
local skyExt      = require("extensions/sky")
local constants   = require("constants")
local daycycle    = require("utils.daycycle")
local JointLayout = require("src.utils.joint_layout")
local NoteSystem  = require("src.systems.note_system")
local camera      = require("camera")
local A           = require("src.input.actions")
local Colors = require("src.utils.colors")
local materials = require("src.utils.materials")

local scene = {
  -- geometry containers
  joints       = {},
  edges        = {},
  curves       = {},
  surfaces     = {},
  labels       = {},   -- raw .obj label meshes
  labelModels  = {},   -- id → mesh lookup
  activeLabels = {},   -- { name, color, position } per frame

  -- visibility toggles
  showJoints   = true,
  showEdges    = true,
  showCurves   = true,
  showSurfaces = true,
  showLabels   = true,
  showDebug    = false,

  -- day/night cycle
  dayTime = constants.day_night,
}

-- pre-load the HDR background image
local hdrImg = love.graphics.newImage(constants.bck_image)

-- forward declaration
local sun

-- load all .obj files from assets/models/<folder>
-- local function loadCategory(folder, out, dream)
--   local base = "assets/models/" .. folder .. "/"
--   for _, file in ipairs(lfs.getDirectoryItems(base)) do
--     if file:match("%.obj$") then
--       local id = file:match("(.+)%.obj")
--       local ok, mesh = pcall(function() return dream:loadObject(base .. id) end)
--       if ok and mesh then
--         mesh.id = id
--         table.insert(out, mesh)
--       else
--         print("⚠️ Failed to load " .. folder .. ": " .. id)
--       end
--     end
--   end
-- end

local function loadCategory(folder, out, dream)
  local base       = "assets/models/" .. folder .. "/"
  local customPath = base .. "materials/custom_object.lua"

  if lfs.getInfo(customPath) then
    -- PHASE 1: custom definitions override
    local defs = require("models." .. folder .. ".materials.custom_object")

    for id, def in pairs(defs) do
      local mesh = dream:loadObject(base .. id)
      if not mesh then
        error(("Failed to load %s for %s"):format(id, folder))
      end

      mesh.id       = id
      mesh.material = dream.materialLibrary[def.material]
      table.insert(out, mesh)
    end

  else
    -- PHASE 2: fallback to loading every OBJ
    for _, file in ipairs(lfs.getDirectoryItems(base)) do
      if file:match("%.obj$") then
        local id, ok, mesh = file:match("(.+)%.obj"), nil, nil
        ok, mesh = pcall(function()
          return dream:loadObject(base .. id)
        end)
        if ok and mesh then
          mesh.id = id
          table.insert(out, mesh)
        else
          print("⚠️ Failed to load " .. folder .. ": " .. id)
        end
      end
    end
  end
end

-- src/scene.lua

function scene.load(dream)
  -- Sun & lighting
  sun = dream:newLight("sun")
  sun:addNewShadow()
  sun:setBrightness(daycycle.computeDaycycle(scene.dayTime))

  -- Load all model categories
  loadCategory("joints",   scene.joints,   dream)
  loadCategory("edges",    scene.edges,    dream)
  loadCategory("curves",   scene.curves,   dream)
  loadCategory("surfaces", scene.surfaces, dream)
  loadCategory("labels",   scene.labels,   dream)

  -- Build label lookup
  for _, mesh in ipairs(scene.labels) do
    scene.labelModels[mesh.id] = mesh
  end

  -- Assign default materials (onyx for joints/labels; metal for others)
  materials.assignAll(
    scene,
    dream.materialLibrary
  )

  -- Initialize note system & labels
  scene.noteSystem = NoteSystem:new(scene)
  scene.updateLabels()
end

function scene.update(dt)
  -- adjust dayTime with + / -
  if love.keyboard.isDown("+", "=") then
    scene.dayTime = (scene.dayTime + constants.day_night_speed) % 24
  elseif love.keyboard.isDown("-") then
    scene.dayTime = (scene.dayTime - constants.day_night_speed) % 24
  end
end

function scene.updateLabels()
  local jointPos        = JointLayout.getJointPositions()
  local triangleCenters = JointLayout.getTriangleCenters()
  local dist            = constants.label_distance

  scene.activeLabels = {}
  for idx = 0, 11 do
    local noteInfo = scene.noteSystem.notes[idx + 1]
    local J = jointPos[idx]
    local C = triangleCenters[(idx % #triangleCenters) + 1]

    local pos = {
      C[1] + (J[1] - C[1]) * dist,
      C[2] + (J[2] - C[2]) * dist,
      C[3] + (J[3] - C[3]) * dist,
    }

    table.insert(scene.activeLabels, {
      name     = noteInfo.name,
      color = Colors.getNoteColor(noteInfo.index, dream),
      position = pos,
    })
  end
end

function scene.draw(dream)
  -- sky & lighting
  dream:addLight(sun)
  local sunFactor, envBrightness = daycycle.computeDaycycle(scene.dayTime)
  skyExt:setDaytime(sun, sunFactor)
  dream:setSky(hdrImg, envBrightness)

  -- draw geometry
  if scene.showJoints   then for _, o in ipairs(scene.joints)   do dream:draw(o) end end
  if scene.showEdges    then for _, o in ipairs(scene.edges)    do dream:draw(o) end end
  if scene.showCurves   then for _, o in ipairs(scene.curves)   do dream:draw(o) end end
  if scene.showSurfaces then for _, o in ipairs(scene.surfaces) do dream:draw(o) end end

  -- draw labels
  if scene.showLabels then

    for i, lbl in ipairs(scene.activeLabels) do
      local mesh = scene.labelModels[lbl.name] or scene.labels[i]
      if not mesh then
	print(("No label mesh for %s"):format(lbl.name))
      else
	local x,y,z     = table.unpack(lbl.position)
	local transform = dream.mat4.getTranslate(x, y, z)

       if constants.dynamicLabelFacing then

         local V = camera.View
	 local rot_offset = 0
	 if V.Pos.z < 0 then rot_offset = - math.pi end
         transform = transform
           * dream.mat4.getRotateY( V.yaw )
           * dream.mat4.getRotateY( rot_offset + math.pi / 2 + math.atan(-V.Pos.z, -V.Pos.x) )
           * dream.mat4.getRotateX( math.pi / 2 + V.pitch )
       end

	dream:draw(mesh, transform * dream.mat4.getScale(1))
      end
    end

  end
end

function scene.pressedAction(action)
  -- rotate map
  if action == A.ROTATE_CW then
    scene.noteSystem:shift(1)
    scene.updateLabels()
    return true
  elseif action == A.ROTATE_CCW then
    scene.noteSystem:shift(-1)
    scene.updateLabels()
    return true
  end

  -- geometry toggles
  if action == A.TOGGLE_JOINTS   then scene.showJoints   = not scene.showJoints   ; return true end
  if action == A.TOGGLE_EDGES    then scene.showEdges    = not scene.showEdges    ; return true end
  if action == A.TOGGLE_CURVES   then scene.showCurves   = not scene.showCurves   ; return true end
  if action == A.TOGGLE_SURFACES then scene.showSurfaces = not scene.showSurfaces ; return true end

  -- label toggle
  if action == A.TOGGLE_LABELS then
    scene.showLabels = not scene.showLabels
    return true
  end

  -- debug overlay toggle
  if action == A.TOGGLE_DEBUG then
    scene.showDebug = not scene.showDebug
    return true
  end

  return false
end

function scene.apply()
  if not scene.showDebug then return end
  local V = camera.View
  love.graphics.setColor(1, 1, 1)

  love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
  love.graphics.print("Day time: " .. daycycle.formatTime(scene.dayTime), 10, 40)
  love.graphics.print(string.format("Camera Pos: (%.2f, %.2f, %.2f)", V.Pos.x, V.Pos.y, V.Pos.z), 10, 60)
  love.graphics.print(string.format("Camera yaw: (%.2f)", V.yaw), 10, 80)
  love.graphics.print(string.format("Camera pitch: (%.2f)",  V.pitch), 10, 100)
end

return scene
