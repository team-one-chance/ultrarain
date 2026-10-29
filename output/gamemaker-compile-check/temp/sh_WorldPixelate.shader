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
uniform vec2 u_grid;
uniform vec2 u_texel;
void main() {
    vec2 uv = (floor(v_vTexcoord * u_grid) + 0.5) / u_grid;
    uv = clamp(uv, u_texel * 0.5, vec2(1.0) - u_texel * 0.5);
    gl_FragColor = texture2D(gm_BaseTexture, uv);
}

