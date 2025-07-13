-- src/scene.lua
local dream = require("3DreamEngine")
local lfs = love.filesystem
local skyExt = require("extensions/sky")

local skyShader = love.graphics.newShader("shaders/skyShader.frag")
dream:registerShader(skyShader, "customSky")  -- optional tag if you want to reuse later

local scene = {}
scene.joints = {}
scene.edges = {}
scene.curves = {}
scene.surfaces = {}

local hdrImg = nil
scene.environmentBrightness = require("constants").brightness
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
  hdrImg:setFilter("linear", "linear")
  hdrImg:setWrap("clamp", "clamp")
  dream:setSky(hdrImg,scene.environmentBrightness)

  loadCategory("joints", scene.joints)
  loadCategory("edges", scene.edges)
  loadCategory("curves", scene.curves)
  loadCategory("surfaces", scene.surfaces)
end

function scene.update(dt)
  dream:setSky(hdrImg, scene.environmentBrightness)

  if love.keyboard.isDown("+") or love.keyboard.isDown("=") then
    scene.environmentBrightness = math.min(scene.environmentBrightness + 0.03, 2.4)
  elseif love.keyboard.isDown("-") then
    scene.environmentBrightness = math.max(scene.environmentBrightness - 0.03, 0.0)
  end

end

function scene.draw()

  skyShader:send("uSkyTexture", hdrImg)
  skyShader:send("uTintColor", {1.0, 0.9, 0.7})
  skyShader:send("uBrightness", scene.environmentBrightness)
  skyShader:send("uIsGlossyRay", false)

  love.graphics.setShader(skyShader)
  love.graphics.draw(hdrImg, 0, 0)
  love.graphics.setShader()

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
