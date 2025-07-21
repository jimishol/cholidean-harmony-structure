-- src/scene.lua

local NoteSystem = require("src.systems.note_system")

local showJoints   = true
local showEdges    = true
local showCurves   = true
local showSurfaces = true

local scene = {}
scene.joints = {}
scene.edges = {}
scene.curves = {}
scene.surfaces = {}
scene.labels = {}
scene.labels = {}

local lfs       = love.filesystem
local skyExt    = require("extensions/sky")
local constants = require("constants")
local daycycle  = require("utils.daycycle")
local Labels    = require("src.labels")
local JointLayout = require("src.utils.joint_layout")
local A = require("src.input.actions")

local dayTime = constants.day_night
local hdrImg  = love.graphics.newImage(constants.bck_image)

local sun  -- reusable light object

function scene.load(dream)
  sun = dream:newLight("sun")
  sun:addNewShadow()

  local sunFactor, envBright = daycycle.computeDaycycle(dayTime)
  sun:setBrightness(sunFactor)

  local function loadCategory(folder, targetTable)
    local basePath = "assets/models/" .. folder .. "/"
    local files = lfs.getDirectoryItems(basePath)

    for _, file in ipairs(files) do
      if file:match("%.obj$") then
        local name = file:match("(.+)%.obj")
        local success, object = pcall(function()
          return dream:loadObject(basePath .. name)
        end)
        if success and object then
	  object.id = name
          table.insert(targetTable, object)
        else
          print("⚠️ Failed to load " .. folder .. ": " .. name)
        end
      end
    end
  end

  loadCategory("joints", scene.joints)
  loadCategory("edges", scene.edges)
  loadCategory("curves", scene.curves)
  loadCategory("surfaces", scene.surfaces)
  loadCategory("labels", scene.surfaces)

  scene.noteSystem = NoteSystem:new(scene)
  scene.updateLabels()

end

function scene.update(dt)
  if love.keyboard.isDown("+", "=") then
    dayTime = dayTime + constants.day_night_speed
  elseif love.keyboard.isDown("-") then
    dayTime = dayTime - constants.day_night_speed
  end
end

function scene.draw(dream)
  dream:addLight(sun)
  local sunFactor, envBright = daycycle.computeDaycycle(dayTime)
  skyExt:setDaytime(sun, sunFactor)
  dream:setSky(hdrImg, envBright)

  if showJoints then
    for _, obj in ipairs(scene.joints) do
      dream:draw(obj)
    end
  end
  if showEdges then
    for _, obj in ipairs(scene.edges) do
      dream:draw(obj)
    end
  end
  if showCurves then
    for _, obj in ipairs(scene.curves) do
      dream:draw(obj)
    end
  end
  if showSurfaces then
    for _, obj in ipairs(scene.surfaces) do
      dream:draw(obj)
    end
  end

  -- …inside scene.draw(dream) after surfaces…
  if showLabels then
    for _, lbl in ipairs(scene.activeLabels) do
      local mesh = scene.labelModels[lbl.name]
      if mesh then
        local obj = dream:spawn(mesh)
        local x,y,z = table.unpack(lbl.position)
        local t = dream.mat4.getTranslate(x,y,z) * dream.mat4.getScale(0.01)
        obj:setTransform(t)

        local m = obj:getMaterial()
        if lbl.color then
          m:setColor(table.unpack(lbl.color))
        end
        m:setMetallic(1)
        m:setRoughness(0.1)
      end
    end
  end

end

function scene.updateLabels()
  local jointPos        = JointLayout.getJointPositions()
  local triangleCenters = JointLayout.getTriangleCenters()
  local dist            = constants.label_distance or 1.0
  local fontSize        = constants.label_font_size or 18

  -- gather 12 labels with name, color & position
  scene.activeLabels = {}
  for idx = 0, 11 do
    local noteInfo = scene.noteSystem.notes[idx+1]
    local J = jointPos[idx]
    local C = triangleCenters[idx % 4 + 1]
    local pos = {
      C[1] + (J[1] - C[1]) * dist,
      C[2] + (J[2] - C[2]) * dist,
      C[3] + (J[3] - C[3]) * dist,
    }

    scene.activeLabels[idx+1] = {
      name     = noteInfo.name,
      color    = constants.COLOR_MAP[noteInfo.name],
      position = pos,
      isTonic  = (idx == 0),
      fontSize = fontSize,
    }
  end
end

function scene.pressedAction(action)
  -- handle note‐map shifts first
  if action == A.ROTATE_CW then
    scene.noteSystem:shift(1)
    scene.updateLabels()
    return true
  elseif action == A.ROTATE_CCW then
    scene.noteSystem:shift(-1)
    scene.updateLabels()
    return true
  end

  if action == A.TOGGLE_JOINTS then
    showJoints = not showJoints
    return true
  elseif action == A.TOGGLE_EDGES then
    showEdges = not showEdges
    return true
  elseif action == A.TOGGLE_CURVES then
    showCurves = not showCurves
    return true
  elseif action == A.TOGGLE_SURFACES then
    showSurfaces = not showSurfaces
    return true
  end
  return false
end

return scene
