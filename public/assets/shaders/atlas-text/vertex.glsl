#version 300 es

in vec3 vertexPosition;
in vec3 vertexColor;

out vec3 vColor;

uniform mat4 view;
uniform mat4 proj;

void main() {
    vColor = vertexColor;
    vec4 p = proj * view * (vec4(vertexPosition, 1.0));
    gl_Position = vec4(p.xy, 0.0, p.w);
}