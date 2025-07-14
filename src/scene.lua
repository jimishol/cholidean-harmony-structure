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


local scene = {}
scene.joints = {}
scene.edges = {}
scene.curves = {}
scene.surfaces = {}
hdrImg = love.graphics.newImage("assets/sky/DaySkyHDRI021A_4K.hdr")

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
end

return scene
