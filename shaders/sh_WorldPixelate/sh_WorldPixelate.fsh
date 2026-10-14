varying vec2 v_vTexcoord;
varying vec4 v_vColour;
uniform vec2 u_grid;
uniform vec2 u_texel;
void main() {
    vec2 uv = (floor(v_vTexcoord * u_grid) + 0.5) / u_grid;
    uv = clamp(uv, u_texel * 0.5, vec2(1.0) - u_texel * 0.5);
    gl_FragColor = texture2D(gm_BaseTexture, uv);
}
