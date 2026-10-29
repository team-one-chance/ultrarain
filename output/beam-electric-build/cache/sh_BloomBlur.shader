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

