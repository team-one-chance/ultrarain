attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
void main() {
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1.0);
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
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

