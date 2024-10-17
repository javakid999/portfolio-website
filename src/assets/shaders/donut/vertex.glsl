#version 300 es

in vec2 vertexPosition;
in vec2 vertexColor;
out vec2 fragPos;

void main() {
    gl_Position = vec4(vertexPosition, 0.0, 1.0);
    fragPos = vertexColor;
}