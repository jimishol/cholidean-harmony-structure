-- src/scene.lua

local lfs         = love.filesystem
local skyExt      = require("extensions/sky")
local constants   = require("constants")
local daycycle    = require("utils.daycycle")
local JointLayout = require("src.utils.joint_layout")
local NoteSystem  = require("src.systems.note_system")
local camera      = require("camera")
local A           = require("src.input.actions")
local Colors      = require("src.utils.colors")
local materials   = require("src.utils.materials")

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
local sun, sunFactor, envBrightness

local fillLight, headLight         -- our torus‐center fill light & camera headlight
scene.showTorusLights = false     -- start with both off

local function loadCategory(folder, out, dream)
  local base       = "assets/models/" .. folder .. "/"
  local customPath = base .. "materials/custom_object.lua"

  if lfs.getInfo(customPath) then
    -- PHASE 1: custom definitions override
    local defs = require("models." .. folder .. ".materials.custom_object")

    local sorted_ids = {}

    for id, _ in pairs(defs) do
      table.insert(sorted_ids, id)
    end

    table.sort(sorted_ids)

    for _, id in pairs(sorted_ids) do
      local def = defs[id]
      local mesh = dream:loadObject(base .. id)
      if not mesh then
        error(("Failed to load %s for %s"):format(id, folder))
      end
      mesh.name       = id
      mesh.material = dream.materialLibrary[def.material]
      table.insert(out, mesh)
    end
  end
end

function scene.load(dream)
   local vec3        = dream.vec3
   -- 1) Static point‐fill light at origin (subtle night glow)
   fillLight = dream:newLight("point", vec3(0,0,0))
   fillLight:setColor(1, 1, 1)
   fillLight:setBrightness(constants.nightLightOrigin)      -- low intensity
   fillLight:setAttenuation(2)

   -- 2) Camera‐locked spotlight (like a torch)
    headLight = dream:newLight("point")
    headLight:setColor(1, 1, 1)
    headLight:setBrightness(constants.nightLightCamera)      -- modest beam
    headLight:setAttenuation(2)         -- soft edge
   -- never call headLight:addIndicator() → stays invisible

  scene.materialLibrary = dream.materialLibrary
  materials.init(dream)

    -- Sun & lighting
  sun = dream:newLight("sun")
  sun:addNewShadow()
  skyExt:setSunOffset(0.42,0)
  sunFactor, envBrightness = daycycle.computeDaycycle(scene.dayTime)
  sun:setBrightness(constants.sunBrightness * envBrightness)
  skyExt:setDaytime(sun, sunFactor)

  if constants.autoExposure.enabled then
    dream:setAutoExposure(
      constants.autoExposure.target,
      constants.autoExposure.speed
    )
  else
    dream:setAutoExposure(false)
  end

  -- Load all model categories
  loadCategory("joints",   scene.joints,   dream)
  loadCategory("edges",    scene.edges,    dream)
  loadCategory("curves",   scene.curves,   dream)
  loadCategory("surfaces", scene.surfaces, dream)
  loadCategory("labels",   scene.labels,   dream)

  -- Give each mesh its own material clone so we can recolor it later:
  local function makeInstances(list, matKey)
    for _, mesh in ipairs(list) do
      local base = dream.materialLibrary[matKey]
      local inst = base:clone()
      mesh._matInst  = inst        -- store it for future recolor
      mesh._matKey   = matKey      -- remember which base it came from
      -- apply it immediately so draw() picks it up
      if mesh.setMaterial then
        mesh:setMaterial(inst)
      elseif mesh.geometry then
        mesh.geometry:setMaterial(0, inst)
      end
    end
  end

  makeInstances(scene.joints,   "onyx")
  makeInstances(scene.edges,    "metal")
  makeInstances(scene.curves,   "metal")
  makeInstances(scene.surfaces, "metal")
  makeInstances(scene.labels, "onyx")

  -- note: we skip `scene.labels` here so labels keep their original material/color

  -- Build label lookup
  for _, mesh in ipairs(scene.labels) do
    scene.labelModels[mesh.name] = mesh
  end

  -- Initialize note system & labels
  scene.noteSystem = NoteSystem:new(scene)
  scene.updateLabels()

  -- Assign default materials (onyx for joints/labels; metal for others)
  materials.assignAll(
    scene,
    dream.materialLibrary,
    scene.noteSystem
  )

end

local firstFrame = true

function scene:update(dt)

  if firstFrame then
    sunFactor, envBrightness = daycycle.computeDaycycle(04.00)
    sun:setBrightness(constants.sunBrightness * envBrightness)
    skyExt:setDaytime(sun, sunFactor)
  end

  -- adjust dayTime with + / -
  if love.keyboard.isDown("+", "=") then
    scene.dayTime = (scene.dayTime + constants.day_night_speed) % 24
    sunFactor, envBrightness = daycycle.computeDaycycle(scene.dayTime)
    sun:setBrightness(constants.sunBrightness * envBrightness)
    skyExt:setDaytime(sun, sunFactor)
  elseif love.keyboard.isDown("-") then
    scene.dayTime = (scene.dayTime - constants.day_night_speed) % 24
    sunFactor, envBrightness = daycycle.computeDaycycle(scene.dayTime)
    sun:setBrightness(constants.sunBrightness * envBrightness)
    skyExt:setDaytime(sun, sunFactor)
  end

  -- Poll NoteSystem; only reassign if something actually changed
  local notesChanged = self.noteSystem:update(dt)
  if notesChanged then
    -- shake up labels & materials
    self:updateLabels()                 -- your existing label‐update helper
    materials.assignAll(
      self, self.materialLibrary, self.noteSystem
    )
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

    -- Destructure RGB from stored engine
    local r, g, b = Colors.getNoteColor(noteInfo.index)

    table.insert(scene.activeLabels, {
      name     = noteInfo.name,
      color    = { r, g, b },      -- now a proper RGB table
      position = pos,
      active   = noteInfo.active,  -- you can use this in assignAll
    })
  end
end

function scene.draw(dream)

  dream:addLight(sun)
  dream:setSky(hdrImg, envBrightness)

  if firstFrame then
    sunFactor, envBrightness = daycycle.computeDaycycle(scene.dayTime)
    sun:setBrightness(constants.sunBrightness * envBrightness)
    skyExt:setDaytime(sun, sunFactor)
    firstFrame = false
  end

    sunFactor, envBrightness = daycycle.computeDaycycle(scene.dayTime)
    sun:setBrightness(constants.sunBrightness * envBrightness)
    skyExt:setDaytime(sun, sunFactor)

  -- sky & lighting
  if scene.showTorusLights then
    dream:addLight(fillLight)
    local V = camera.View
    headLight:setPosition(V.Pos.x, V.Pos.y, V.Pos.z)
    dream:addLight(headLight)
  end

  -- draw geometry
  if scene.showJoints then
    local jointPos        = JointLayout.getJointPositions()
    local angle    = math.pi / 5

    for idx = 0, 11 do
      local noteInfo = scene.noteSystem.notes[idx + 1]
      local J = jointPos[idx]

      local s = constants.jointScale
      if noteInfo and noteInfo.active then
        s = s * constants.scaleFactor
      end

      -- Build transform: scale around joint position
      local transform =
        dream.mat4.getTranslate(J[1], J[2], J[3])
        * dream.mat4.getScale(s)
        * dream.mat4.getTranslate(-J[1], -J[2], -J[3])

      -- Draw joint mesh
      local jointMesh = scene.joints[idx + 1]
      dream:draw(jointMesh, transform)
--      print(noteInfo.name, "is bass = ", noteInfo.isBass)
      if noteInfo.isBass then
	transform =
	    dream.mat4.getTranslate(J[1], J[2], J[3])
            * dream.mat4.getRotateY(angle)
	    * dream.mat4.getScale(s)
	    * dream.mat4.getTranslate(-J[1], -J[2], -J[3])

        dream:draw(jointMesh, transform)
      end
    end
  end

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

        -- apply base scale, then enlarge if active
        local baseScale = constants.label_scale
        if lbl.active then
           baseScale = baseScale * constants.label_active_scale
        end

        dream:draw(mesh, transform * dream.mat4.getScale(baseScale))
      end
    end

  end
end

function scene.pressedAction(action)
  -- rotate map
  if action == A.ROTATE_CW then
    scene.noteSystem:shift(1)
    scene.updateLabels()
    materials.assignAll(scene, scene.materialLibrary, scene.noteSystem)
    return true
  elseif action == A.ROTATE_CCW then
    scene.noteSystem:shift(-1)
    scene.updateLabels()
    materials.assignAll(scene, scene.materialLibrary, scene.noteSystem)
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

  if action == A.TOGGLE_TORUS_LIGHTS then
    scene.showTorusLights = not scene.showTorusLights
    return true
  end
  -- 🎵 NEW: note mode toggle
  if action == A.TOGGLE_NOTE_MODE then
    scene.noteMode = (scene.noteMode == "on_off") and "heard_unheard" or "on_off"
    print("Note Mode switched to: " .. scene.noteMode)
    scene.apply()
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
  love.graphics.print(string.format("Camera Pos : (%.2f, %.2f, %.2f)", V.Pos.x, V.Pos.y, V.Pos.z), 10, 60)
  love.graphics.print(string.format("Camera FOV: (%.2f)", V.fov), 10, 80)
  love.graphics.print("Note Mode  : " .. (scene.noteMode == "on_off" and "ON/OFF" or "HEARD/UNHEARD"), 10, 100)
end

return scene
