-- src/scene.lua
local dream = require("3DreamEngine")
local lfs = love.filesystem
--local skyShader = love.graphics.newShader("shaders/skyShader.frag")
--dream:registerShader(skyShader, "customSky")  -- optional tag if you want to reuse later

local skyExt = require("extensions/sky")
local sun = dream:newLight("sun")

local constants = require("constants")
local daycycle = require("utils.daycycle")
local dayTime  = constants.day_night  -- your starting hour


local scene = {}
scene.joints = {}
scene.edges = {}
scene.curves = {}
scene.surfaces = {}

hdrImg = love.graphics.newImage("assets/sky/DaySkyHDRI021A_4K.hdr")
local sunFactor, envBright = daycycle.computeDaycycle(dayTime)
dream:setSky(hdrImg, envBright)

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
--dream:setSky(skyExt.render)
dream:setSky(hdrImg, envBright)

sun:addNewShadow()
--  hdrImg:setFilter("linear", "linear")
--  hdrImg:setWrap("clamp", "clamp")
--  dream:setSky(hdrImg,bright, "customSky")

  loadCategory("joints", scene.joints)
  loadCategory("edges", scene.edges)
  loadCategory("curves", scene.curves)
  loadCategory("surfaces", scene.surfaces)
end

function scene.update(dt)
  -- bump dayTime with +/– as before
  if love.keyboard.isDown("+","=") then
    dayTime = math.min(dayTime + 0.5, 24)
  elseif love.keyboard.isDown("-") then
    dayTime = math.max(dayTime - 0.5, 0)
  end

  -- get the two values
  sunFactor, envBright = daycycle.computeDaycycle(dayTime)

  -- apply them
  skyExt:setDaytime(sun, sunFactor)
  dream:setSky(hdrImg, envBright)

  print(string.format(
    "Hour %.2f → sun=%.3f env=%.2f",
    dayTime, sunFactor, envBright
  ))
end

function scene.draw()

  dream:addLight(sun)
  -- skyShader:send("uSkyTexture", hdrImg)
  -- skyShader:send("uTintColor", {1.0, 0.9, 0.7})
  -- skyShader:send("uBrightness", bright)
  -- skyShader:send("uIsGlossyRay", false)

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
