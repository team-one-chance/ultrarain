varying vec2 v_vTexcoord;
varying vec4 v_vColour;
uniform vec3 u_glow_color;
uniform float u_tolerance;
uniform float u_feather;
uniform float u_min_brightness;
void main() {
    vec4 texel = texture2D(gm_BaseTexture, v_vTexcoord);
    float brightness = max(texel.r, max(texel.g, texel.b));
    float target_brightness = max(u_glow_color.r, max(u_glow_color.g, u_glow_color.b));
    // Match hue independently of brightness so blue accent shades stay coherent.
    vec3 hue = texel.rgb / max(brightness, 0.001);
    vec3 target_hue = u_glow_color / max(target_brightness, 0.001);
    float difference = distance(hue, target_hue);
    float selected = 1.0 - smoothstep(u_tolerance, u_tolerance + max(u_feather, 0.001), difference);
    selected *= smoothstep(u_min_brightness, min(u_min_brightness + 0.1, 1.0), brightness);
    // Opaque non-glowing body parts still occlude rear-arm emission correctly.
    gl_FragColor = vec4(texel.rgb * v_vColour.rgb * selected, texel.a * v_vColour.a);
}
