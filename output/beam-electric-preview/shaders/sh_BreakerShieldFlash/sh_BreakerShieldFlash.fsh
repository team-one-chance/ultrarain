varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec2 v_vPosition;
uniform vec4 u_shield_axis;
uniform float u_shield_radius;
uniform float u_flash;
uniform float u_whole_body;
uniform vec4 u_eye_axis; // Eye segment endpoints in room pixels.
uniform vec3 u_eye_color; // Exact eye RGB color, each channel 0-1; applied after white damage flashes.
uniform float u_eye_radius; // Eye segment thickness radius in room pixels.
uniform float u_eye_active; // 1 recolors the eyes; 0 leaves the original eye pixels intact.
uniform float u_eye_only; // 1 draws just the opaque colored eye pixels after room lighting.
void main() {
    vec4 texel = texture2D(gm_BaseTexture, v_vTexcoord);
    vec2 eye_axis = u_eye_axis.zw - u_eye_axis.xy;
    vec2 eye_delta = v_vPosition - u_eye_axis.xy;
    float eye_along = clamp(dot(eye_delta, eye_axis) / max(dot(eye_axis, eye_axis), 0.001), 0.0, 1.0);
    float eye_mask = (1.0 - step(u_eye_radius, length(eye_delta - eye_along * eye_axis))) * u_eye_active;
    if (u_eye_only > 0.5) {
        gl_FragColor = vec4(u_eye_color, texel.a * v_vColour.a * eye_mask);
        return;
    }
    float red = step(45.0 / 255.0, texel.r)
        * step(texel.g * 1.4, texel.r) * step(texel.b * 1.4, texel.r);
    vec2 axis = u_shield_axis.zw - u_shield_axis.xy;
    vec2 delta = v_vPosition - u_shield_axis.xy;
    float along = clamp(dot(delta, axis) / max(dot(axis, axis), 0.001), 0.0, 1.0);
    float on_shield = 1.0 - step(u_shield_radius, length(delta - along * axis));
    vec4 colour = texel * v_vColour;
    float flash_area = mix(on_shield, 1.0, u_whole_body);
    colour.rgb = mix(colour.rgb, vec3(1.0), red * flash_area * u_flash);
    colour.rgb = mix(colour.rgb, u_eye_color, eye_mask);
    gl_FragColor = colour;
}
