uniform sampler2D uSkyTexture;
uniform vec3 uTintColor;
uniform float uBrightness;
uniform bool uIsGlossyRay;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec4 texColor = Texel(uSkyTexture, texture_coords);  // 👈 This line is essential

    vec3 adjusted = texColor.rgb * uTintColor * uBrightness;

    if (uIsGlossyRay) {
        return vec4(adjusted, texColor.a);
    } else {
        return vec4(adjusted * 0.5, texColor.a);
    }
}
