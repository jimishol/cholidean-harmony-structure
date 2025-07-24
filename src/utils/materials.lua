local M = {}

function M.assignAll(dream, scene)
  -- pull the already‐loaded materials by their folder names:
  local onyx  = dream.materialLibrary["Onyx001_4K-PNG"]
  local metal = dream.materialLibrary["Metal014_4K-PNG"]

  for _, m in ipairs(scene.joints)   do m.material = onyx  end
  for _, m in ipairs(scene.labels)   do m.material = onyx  end
  for _, m in ipairs(scene.edges)    do m.material = metal end
  for _, m in ipairs(scene.curves)   do m.material = metal end
  for _, m in ipairs(scene.surfaces) do m.material = metal end
end

return M
