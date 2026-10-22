varying vec2 v_vTexcoord;
varying vec4 v_vColour;
uniform float u_threshold;
uniform float u_gain;
void main() {
    vec4 texel = texture2D(gm_BaseTexture, v_vTexcoord);
    vec3 color = texel.rgb * v_vColour.rgb;
    float brightness = max(color.r, max(color.g, color.b));
    float weight = smoothstep(u_threshold, min(u_threshold + 0.15, 1.0), brightness);
    // Preserve sprite coverage and source strength when extracting emitters.
    gl_FragColor = vec4(color * weight * u_gain, texel.a * v_vColour.a);
}
