attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec2 v_vPosition;

void main()
{
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION]
        * vec4(in_Position, 1.0);

    v_vTexcoord = in_TextureCoord;
    v_vColour = in_Colour;
    v_vPosition = in_Position.xy;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec2 v_vPosition;

uniform float u_time;
uniform float u_rainbow;
uniform float u_q4;

void main()
{
    float alpha = texture2D(
        gm_BaseTexture,
        v_vTexcoord
    ).a * v_vColour.a;

    vec3 colour = v_vColour.rgb;

    if (u_rainbow > 0.5)
    {
        float phase =
            (v_vPosition.x + v_vPosition.y) * 0.085
            - u_time * 2.5;

        colour = 0.5 + 0.5 * cos(
            phase + vec3(0.0, 2.094395, 4.188790)
        );
    }
    else if (u_q4 > 0.5)
    {
        vec3 cyan = vec3(0.0, 0.92, 1.0);
        vec3 purple = vec3(0.68, 0.20, 1.0);

        // Cyan-purple gradient along the outline.
        float gradient = 0.5 + 0.5 * sin(
            (v_vPosition.x - v_vPosition.y) * 0.065
        );

        colour = mix(cyan, purple, gradient);

        // Narrow white sheen travelling diagonally.
        float sheen = pow(
            max(
                0.0,
                cos(
                    (v_vPosition.x + v_vPosition.y) * 0.09
                    - u_time * 3.0
                )
            ),
            32.0
        );

        colour = mix(colour, vec3(1.0), sheen * 0.85);
    }

    gl_FragColor = vec4(colour, alpha);
}

