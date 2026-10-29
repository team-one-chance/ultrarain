varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_alpha;

void main()
{
    float alpha = texture2D(gm_BaseTexture, v_vTexcoord).a * v_vColour.a;
    gl_FragColor = vec4(1.0, 0.0, 0.0, alpha * u_alpha);
}
