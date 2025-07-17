-- src/scene.lua
local dream = require("3DreamEngine")
local lfs = love.filesystem

local skyExt = require("extensions/sky")
--dream:setSky(skyExt.render)
--dream:setSky(hdrImg, envBright)
local sun = dream:newLight("sun")
sun:addNewShadow()

local constants = require("constants")
local daycycle = require("utils.daycycle")
local dayTime  = constants.day_night  -- your starting hour

local Labels = require("src.labels")

local scene = {}
scene.joints = {}
scene.edges = {}
scene.curves = {}
scene.surfaces = {}
hdrImg = love.graphics.newImage(constants.bck_image)

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

function scene.load()
  local sunFactor, envBright = daycycle.computeDaycycle(dayTime)
--  dream:setSky(hdrImg, envBright)
--  dream:setSky(skyExt.render)
  sun:setBrightness(sunFactor)

  loadCategory("joints", scene.joints)
  loadCategory("edges", scene.edges)
  loadCategory("curves", scene.curves)
  loadCategory("surfaces", scene.surfaces)

  local JointLayout = require("src.utils.joint_layout")
  local jointPos = JointLayout.getJointPositions()

    local JointLayout = require("src.utils.joint_layout")
    local jointPos = JointLayout.getJointPositions()
    local labelDistance = constants.label_distance or 1.0
    local fontSize = constants.label_font_size or 18
    local allLabels = Labels.get()

    for id = 0, 11 do
      local P = jointPos[id]
      local vx, vy, vz = P[1], P[2], P[3]
      local mag = math.sqrt(vx^2 + vy^2 + vz^2)
      local ux, uy, uz = vx / mag, vy / mag, vz / mag

      local labelPos = {
	P[1] + labelDistance * ux,
	P[2] + labelDistance * uy,
	P[3] + labelDistance * uz
      }

      local label = allLabels[id + 1]
      label.position = labelPos
      label.name = string.format("Lbl%02d", id)
      label.fontSize = fontSize
      label.color = {1, 1, 0}  -- default visible yellow
    end
end

function scene.update(dt)
  -- bump dayTime with +/– as before
  if love.keyboard.isDown("+","=") then
    dayTime = dayTime + constants.day_night_speed
  elseif love.keyboard.isDown("-") then
    dayTime = dayTime - constants.day_night_speed
  end
end

function scene.draw()
  dream:addLight(sun)
  local sunFactor, envBright = daycycle.computeDaycycle(dayTime)
  skyExt:setDaytime(sun, sunFactor)
  dream:setSky(hdrImg, envBright)

  for _, obj in ipairs(scene.joints) do
    dream:draw(obj)
  end
  for _, obj in ipairs(scene.edges) do
    dream:draw(obj)
  end
  for _, obj in ipairs(scene.curves) do
    dream:draw(obj)
  end
  for _, obj in ipairs(scene.surfaces) do
    dream:draw(obj)
  end
  Labels.draw3D(dream)
end

return scene
