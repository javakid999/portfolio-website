#version 300 es

precision highp float;

in vec2 fragPos;
in vec3 cColor;
out vec4 fragColor;

void main() {
    if (length(fragPos-0.5) > 0.5) {
        discard;
    } else {
        fragColor = vec4((cColor), 1.0);
    }
}