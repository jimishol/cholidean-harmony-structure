-- src/utils/materials.lua
local M = {}

local function makeOnyx(dream)
  local mat = dream:newMaterial()
  mat:setAlbedoTexture    ("assets/materials/Onyx001_4K-PNG/Color.png")
  mat:setNormalTexture    ("assets/materials/Onyx001_4K-PNG/NormalGL.png")
  mat:setRoughnessTexture ("assets/materials/Onyx001_4K-PNG/Roughness.png")
  mat:setMetallicTexture ("assets/materials/Onyx001_4K-PNG/Metalness.png")
  dream:registerMaterial(mat, "onyx")
  return mat
end

local function makeMetal(dream)
  local mat = dream:newMaterial()
  mat:setAlbedoTexture    ("assets/materials/Metal014_4K-PNG/Color.png")
  mat:setNormalTexture    ("assets/materials/Metal014_4K-PNG/NormalGL.png")
  mat:setRoughnessTexture ("assets/materials/Metal014_4K-PNG/Roughness.png")
  mat:setMetallicTexture ("assets/materials/Metal014_4K-PNG/Metalness.png")
  dream:registerMaterial(mat, "metal")
  return mat
end

function M.assignAll(dream, scene)
  local onyx  = makeOnyx(dream)
  local metal = makeMetal(dream)

  for _, m in ipairs(scene.joints)   do m.material = onyx  end
  for _, m in ipairs(scene.labels)   do m.material = onyx  end
  for _, m in ipairs(scene.edges)    do m.material = metal end
  for _, m in ipairs(scene.curves)   do m.material = metal end
  for _, m in ipairs(scene.surfaces) do m.material = metal end
end

return M
