varying vec2 v_vTexcoord;
varying vec4 v_vColour;
uniform float u_threshold;
void main() {
    vec3 color = texture2D(gm_BaseTexture, v_vTexcoord).rgb;
    float brightness = max(color.r, max(color.g, color.b));
    float weight = smoothstep(u_threshold, min(u_threshold + 0.15, 1.0), brightness);
    gl_FragColor = vec4(color * weight, 1.0);
}
