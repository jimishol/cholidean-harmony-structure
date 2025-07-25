-- assets/materials_dx/metal.lua

return {
  metal = {
    shader       = "pbr-metallic-roughness",
    albedoMap    = "metal_albedo.png",
    roughnessMap = "metal_roughness.png",
    metallicMap  = "metal_metallic.png",
    normalMap    = "metal_normal.png",
    specularColor = {1.0, 1.0, 1.0},
    IOR           = 2.5,
  }
}
