varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec2 v_vPosition;
uniform vec4 u_shield_axis;
uniform float u_shield_radius;
uniform float u_flash;
uniform float u_whole_body;
void main() {
    vec4 texel = texture2D(gm_BaseTexture, v_vTexcoord);
    vec2 axis = u_shield_axis.zw - u_shield_axis.xy;
    vec2 delta = v_vPosition - u_shield_axis.xy;
    float along = clamp(dot(delta, axis) / max(dot(axis, axis), 0.001), 0.0, 1.0);
    float on_shield = 1.0 - step(u_shield_radius, length(delta - along * axis));
    float red = step(45.0 / 255.0, texel.r)
        * step(texel.g * 1.4, texel.r) * step(texel.b * 1.4, texel.r);
    vec4 colour = texel * v_vColour;
    float flash_area = mix(on_shield, 1.0, u_whole_body);
    colour.rgb = mix(colour.rgb, vec3(1.0), red * flash_area * u_flash);
    gl_FragColor = colour;
}
