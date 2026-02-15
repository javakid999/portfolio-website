#version 300 es

in vec2 vertexPosition;
in vec2 vertexColor;
in vec3 circleColor;
out vec3 cColor;
out vec2 fragPos;

void main() {
    gl_Position = vec4(vertexPosition, 0.0, 1.0);
    fragPos = vertexColor*2.0-vec2(0.5,0.0);
    cColor = circleColor;
}