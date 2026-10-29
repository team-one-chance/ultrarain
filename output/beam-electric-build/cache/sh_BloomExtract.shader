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

