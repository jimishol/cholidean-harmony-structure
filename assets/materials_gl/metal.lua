-- assets/materials/metal.lua

return {
  metal = {
    shader        = "pbr-metallic-roughness",
    albedoMap     = "metal_albedo.png",
    normalMap     = "metal_normal.png",
    roughnessMap  = "metal_roughness.png",
    metallicMap   = "metal_metallic.png",
    specularColor = {1.0, 1.0, 1.0},
    IOR           = 2.5,
  }
}
