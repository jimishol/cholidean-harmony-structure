-- src/scene.lua

local showJoints   = true
local showEdges    = true
local showCurves   = true
local showSurfaces = true

local scene = {}
scene.joints = {}
scene.edges = {}
scene.curves = {}
scene.surfaces = {}

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

  Labels.draw3D(dream)
end

function scene.updateLabels()
  local jointPos        = JointLayout.getJointPositions()
  local triangleCenters = JointLayout.getTriangleCenters()
  local labelDistance   = constants.label_distance or 1.0
  local fontSize        = constants.label_font_size or 18
  local allLabels       = Labels.get()

  for id = 0, 11 do
    local J = jointPos[id]
    local C = triangleCenters[id % 4 + 1]

    local labelPos = {
      C[1] + (J[1] - C[1]) * labelDistance,
      C[2] + (J[2] - C[2]) * labelDistance,
      C[3] + (J[3] - C[3]) * labelDistance
    }

    local label = allLabels[id + 1]
    label.position = labelPos
    label.name     = string.format("Lbl%02d", id)
    label.fontSize = fontSize
    label.color    = {1, 1, 0}
  end
end

function scene.pressedAction(action)
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
