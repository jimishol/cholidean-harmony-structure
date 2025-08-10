--- Scene module for loading, updating, and rendering the toroidal harmony visualization.
-- Manages model loading, materials, lighting, the note system, input handling,
-- and debug overlay.
-- @module src.scene

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

--- Main scene table.
-- @table scene
-- @field table    joints           Joint meshes
-- @field table    edges            Edge meshes
-- @field table    curves           Curve meshes
-- @field table    surfaces         Surface meshes
-- @field table    labels           Raw OBJ label meshes
-- @field table    labelModels      Lookup name→label mesh
-- @field table    labels_to_Draw   Frame‐specific label definitions
-- @field boolean  showJoints
-- @field boolean  showEdges
-- @field boolean  showCurves
-- @field boolean  showSurfaces
-- @field boolean  showLabels
-- @field boolean  showDebug
-- @field boolean  showTorusLights
-- @field number   dayTime          Current time of day in hours
local scene = {
  joints         = {},
  edges          = {},
  curves         = {},
  surfaces       = {},
  labels         = {},
  labelModels    = {},
  labels_to_Draw = {},

  showJoints     = true,
  showEdges      = true,
  showCurves     = true,
  showSurfaces   = true,
  showLabels     = true,
  showDebug      = false,
  showTorusLights= false,

  dayTime        = constants.day_night,
}

-- preload HDR background
local hdrImg = love.graphics.newImage(constants.bck_image)

-- forward‐declared lights and sun state
local sun, sunFactor, envBrightness
local fillLight, headLight

--- Helper to load a category of models, using custom definitions if present.
-- @local
-- @tparam string folder  Subfolder under `assets/models/`
-- @tparam table  out     Table to populate with loaded meshes
-- @tparam table  dream   Dream framework instance
-- @return nil
local function loadCategory(folder, out, dream)
  local base       = "assets/models/" .. folder .. "/"
  local customPath = base .. "materials/custom_object.lua"

  if lfs.getInfo(customPath) then
    local defs = require("models." .. folder .. ".materials.custom_object")
    local sorted_ids = {}

    for id in pairs(defs) do
      table.insert(sorted_ids, id)
    end
    table.sort(sorted_ids)

    for _, id in ipairs(sorted_ids) do
      local def  = defs[id]
      local mesh = dream:loadObject(base .. id)
      if not mesh then
        error(("Failed to load %s for %s"):format(id, folder))
      end
      mesh.name     = id
      mesh.material = dream.materialLibrary[def.material]
      table.insert(out, mesh)
    end
  end
end

--- Helper to create material instances for a list of meshes.
-- Optionally creates a black emissive clone for bass‐scale rendering.
-- @local
-- @tparam table   list        Array of meshes
-- @tparam string  matKey      Key into `dream.materialLibrary`
-- @tparam boolean black_clone Whether to create a black clone instance
-- @return nil
local function makeInstances(list, matKey, black_clone)
  for idx, mesh in ipairs(list) do
    local base = scene.materialLibrary[matKey]
    local inst = base:clone()
    mesh._matInst = inst
    mesh._matKey  = matKey

    if mesh.setMaterial then
      mesh:setMaterial(inst)
    elseif mesh.geometry then
      mesh.geometry:setMaterial(0, inst)
    end

    if black_clone then
      local blackInst = base:clone()
      blackInst:setColor(Colors.getNoteColor(idx + 6))
      local f = constants.emissionLevels.joints.active
      blackInst:setEmission(f, f, f)
      mesh._matBlack = blackInst
    end
  end
end

--- Initialize and load the entire scene.
-- Sets up lights, sky, exposure, loads geometry, creates instances,
-- initializes the note system, and applies default materials.
-- @tparam table dream        Dream framework instance
-- @tparam table commandMenu  Command‐menu class (for UI controls)
-- @return nil
function scene.load(dream, commandMenu)
  local vec3 = dream.vec3

  -- static fill light
  fillLight = dream:newLight("point", vec3(0,0,0))
  fillLight:setColor(1,1,1)
  fillLight:setBrightness(constants.nightLightOrigin)
  fillLight:setAttenuation(2)

  -- camera‐locked headlight
  headLight = dream:newLight("point")
  headLight:setColor(1,1,1)
  headLight:setBrightness(constants.nightLightCamera)
  headLight:setAttenuation(2)

  scene.materialLibrary = dream.materialLibrary
  materials.init(dream)

  -- sun & sky
  sun = dream:newLight("sun")
  sun:addNewShadow()
  skyExt:setSunOffset(0.42, 0)
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

  -- load model categories
  loadCategory("joints",   scene.joints,   dream)
  loadCategory("edges",    scene.edges,    dream)
  loadCategory("curves",   scene.curves,   dream)
  loadCategory("surfaces", scene.surfaces, dream)
  loadCategory("labels",   scene.labels,   dream)

  -- create instances
  makeInstances(scene.joints,   "onyx",  true)
  makeInstances(scene.edges,    "metal", false)
  makeInstances(scene.curves,   "metal", false)
  makeInstances(scene.surfaces, "metal", false)
  makeInstances(scene.labels,   "onyx",  false)

  -- black clones for joints
  scene.joints_black = {}
  loadCategory("joints", scene.joints_black, dream)
  makeInstances(scene.joints_black, "onyx", true)

  -- label lookup
  for _, mesh in ipairs(scene.labels) do
    scene.labelModels[mesh.name] = mesh
  end

  -- note system & initial labels
  scene.noteSystem = NoteSystem:new(scene)
  scene.updateLabels()

  -- default materials
  materials.assignAll(
    scene,
    dream.materialLibrary,
    scene.noteSystem
  )

  -- initialize command menu (closed)
  scene.commandMenu = commandMenu:new()
end

--- Per-frame update.
-- Advances day/night cycle (when menu closed), polls the note system,
-- and reassigns labels/materials if notes changed.
-- @tparam number dt  Delta time in seconds since last frame
-- @return nil
function scene:update(dt)
  -- first‐frame fixed update
  if hdrImg and not sun then
    -- no-op; handled in load
  end

  -- day/night adjustments if menu closed
  if not self.commandMenu.visible then
    if love.keyboard.isDown("+", "=") then
      self.dayTime = (self.dayTime + constants.day_night_speed) % 24
    elseif love.keyboard.isDown("-") then
      self.dayTime = (self.dayTime - constants.day_night_speed) % 24
    end
    sunFactor, envBrightness = daycycle.computeDaycycle(self.dayTime)
    sun:setBrightness(constants.sunBrightness * envBrightness)
    skyExt:setDaytime(sun, sunFactor)
  end

  -- update notes & materials
  local notesChanged = self.noteSystem:update(dt)
  if notesChanged then
    self:updateLabels()
    materials.assignAll(self, self.materialLibrary, self.noteSystem)
  end
end

--- Update label positions and colors based on current note system.
-- Populates `scene.labels_to_Draw` with name, color, position, and active state.
-- @return nil
function scene.updateLabels()
  local jointPos        = JointLayout.getJointPositions()
  local triangleCenters = JointLayout.getTriangleCenters()
  local dist            = constants.label_distance

  scene.labels_to_Draw = {}
  for idx = 0, 11 do
    local noteInfo = scene.noteSystem.notes[idx + 1]
    local J = jointPos[idx]
    local C = triangleCenters[(idx % #triangleCenters) + 1]

    local pos = {
      C[1] + (J[1] - C[1]) * dist,
      C[2] + (J[2] - C[2]) * dist,
      C[3] + (J[3] - C[3]) * dist,
    }

    local r, g, b = Colors.getNoteColor(noteInfo.index)

    table.insert(scene.labels_to_Draw, {
      name     = noteInfo.name,
      color    = { r, g, b },
      position = pos,
      active   = noteInfo.active,
    })
  end
end

--- Draw the entire scene.
-- Renders sky, lights, joints, edges, curves, surfaces, and labels.
-- @tparam table dream  Dream framework instance
-- @return nil
function scene.draw(dream)
  dream:addLight(sun)
  dream:setSky(hdrImg, envBrightness)

  if scene.showTorusLights then
    dream:addLight(fillLight)
    local V = camera.View
    headLight:setPosition(V.Pos.x, V.Pos.y, V.Pos.z)
    dream:addLight(headLight)
  end

  -- Joints
  if scene.showJoints then
    local jointPos = JointLayout.getJointPositions()
    for idx = 0, 11 do
      local noteInfo = scene.noteSystem.notes[idx + 1]
      local J = jointPos[idx]
      local s = constants.jointScale
      if noteInfo.active then
        s = s * constants.scaleFactor
      end

      -- draw main joint
      local transform =
        dream.mat4.getTranslate(J[1], J[2], J[3])
        * dream.mat4.getScale(s)
        * dream.mat4.getTranslate(-J[1], -J[2], -J[3])
      local jointMesh = scene.joints[idx + 1]
      jointMesh:setMaterial(jointMesh._matInst)
      dream:draw(jointMesh, transform)

      -- draw bass clone
      if noteInfo.isBass then
        local bassTransform =
          dream.mat4.getTranslate(J[1], J[2], J[3])
          * dream.mat4.getRotateY(math.pi / 5)
          * dream.mat4.getScale(constants.bassScale * s)
          * dream.mat4.getTranslate(-J[1], -J[2], -J[3])
        local blackMesh = scene.joints_black[idx + 1]
        blackMesh:setMaterial(blackMesh._matBlack)
        dream:draw(blackMesh, bassTransform)
      end
    end
  end

  if scene.showEdges    then for _, o in ipairs(scene.edges)    do dream:draw(o) end end
  if scene.showCurves   then for _, o in ipairs(scene.curves)   do dream:draw(o) end end
  if scene.showSurfaces then for _, o in ipairs(scene.surfaces) do dream:draw(o) end end

  -- Labels
  if scene.showLabels then
    for _, lbl in ipairs(scene.labels_to_Draw) do
      local mesh = scene.labelModels[lbl.name] or scene.labels[#scene.labels_to_Draw]
      if mesh and mesh._matInst then
        local x, y, z = table.unpack(lbl.position)
        local transform = dream.mat4.getTranslate(x, y, z)

        if constants.dynamicLabelFacing then
          local V = camera.View
          local rot_offset = V.Pos.z < 0 and -math.pi or 0
          transform = transform
            * dream.mat4.getRotateY(V.yaw)
            * dream.mat4.getRotateY(rot_offset + math.pi/2 + math.atan(-V.Pos.z, -V.Pos.x))
            * dream.mat4.getRotateX(math.pi/2 + V.pitch)
        end

        local baseScale = constants.label_scale
        if lbl.active then
          baseScale = baseScale * constants.label_active_scale
        end

        dream:draw(mesh, transform * dream.mat4.getScale(baseScale))
      end
    end
  end
end

--- Handle input actions for scene controls.
-- Supports rotation, toggles, and note‐mode switching.
-- @tparam any action  Action identifier from `src.input.actions`
-- @treturn boolean    True if the action was handled
function scene.pressedAction(action)
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

  if action == A.TOGGLE_JOINTS   then scene.showJoints   = not scene.showJoints   ; return true end
  if action == A.TOGGLE_EDGES    then scene.showEdges    = not scene.showEdges    ; return true end
  if action == A.TOGGLE_CURVES   then scene.showCurves   = not scene.showCurves   ; return true end
  if action == A.TOGGLE_SURFACES then scene.showSurfaces = not scene.showSurfaces ; return true end
  if action == A.TOGGLE_LABELS   then scene.showLabels   = not scene.showLabels   ; return true end
  if action == A.TOGGLE_DEBUG    then scene.showDebug    = not scene.showDebug    ; return true end
  if action == A.TOGGLE_TORUS_LIGHTS then
    scene.showTorusLights = not scene.showTorusLights
    return true
  end

  if action == A.TOGGLE_NOTE_MODE then
    NoteSystem:toggleNoteMode()
    scene.apply()
    return true
  end

  return false
end

--- Draw debug overlay with stats when `showDebug` is true.
-- @return nil
function scene.apply()
  if not scene.showDebug then return end
  local V = camera.View
  love.graphics.setColor(1,1,1)
  love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
  love.graphics.print("Day time: " .. daycycle.formatTime(scene.dayTime), 10, 40)
  love.graphics.print(string.format("Camera Pos: (%.2f,%.2f,%.2f)", V.Pos.x, V.Pos.y, V.Pos.z), 10,60)
  love.graphics.print(string.format("FOV: %.2f", V.fov), 10,80)
  local mode = NoteSystem.noteMode == "instant" and "INSTANT" or "OFFSET"
  love.graphics.print("Note Mode: " .. mode, 10,100)
end

return scene
