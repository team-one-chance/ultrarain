varying vec2 v_vTexcoord;
varying vec4 v_vColour;
void main()
{
    vec4 colour = texture2D(gm_BaseTexture, v_vTexcoord) * v_vColour;
    colour.rgb *= 0.8; // Brightness multiplier: lower values make the far tiles darker.
    gl_FragColor = colour;
}
