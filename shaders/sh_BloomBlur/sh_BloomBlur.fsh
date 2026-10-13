varying vec2 v_vTexcoord;
varying vec4 v_vColour;
uniform vec2 u_step;
void main() {
    // Dense taps prevent thin lines from appearing as separated copies.
    vec3 color = vec3(0.0);
    float total = 0.0;
    for (int i = -8; i <= 8; i++) {
        float offset = float(i);
        float weight = exp(-offset * offset / 8.0);
        vec2 uv = clamp(v_vTexcoord + u_step * offset, vec2(0.0), vec2(1.0));
        color += texture2D(gm_BaseTexture, uv).rgb * weight;
        total += weight;
    }
    gl_FragColor = vec4(color / total, 1.0);
}
