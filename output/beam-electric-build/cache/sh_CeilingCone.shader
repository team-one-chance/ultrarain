attribute vec3 in_Position;
attribute vec4 in_Colour;
varying vec2 v_worldPosition;
varying vec4 v_vColour;
void main() {
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1.0);
    v_worldPosition = in_Position.xy;
    v_vColour = in_Colour;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying vec2 v_worldPosition;
varying vec4 v_vColour;
uniform vec2 u_origin;
uniform vec4 u_transform;
uniform vec4 u_shape;
uniform float u_strength;
uniform float u_dither;
void main() {
    vec2 delta = v_worldPosition - u_origin;
    vec2 local = vec2(delta.x * u_transform.x - delta.y * u_transform.y,
        delta.x * u_transform.y + delta.y * u_transform.x) * u_transform.zw;
    float t = local.y / u_shape.x;
    float halfWidth = max(0.001, u_shape.y + local.y * u_shape.z);
    float u = local.x / halfWidth;
    if (t < 0.0 || t > 1.0 || abs(u) > 1.0) discard;
    float edge = max(0.0, 1.0 - u * u);
    float intensity = u_strength * edge * edge * pow(max(0.0, 1.0 - t), u_shape.w);
    // Spatial noise is anchored to the room, never randomized each frame.
    float noise = fract(sin(dot(floor(v_worldPosition), vec2(12.9898, 78.233))) * 43758.5453) - 0.5;
    vec3 light = v_vColour.rgb * intensity;
    light += vec3(noise * u_dither / 255.0 * min(1.0, intensity * 255.0));
    gl_FragColor = vec4(max(vec3(0.0), light), 1.0);
}

