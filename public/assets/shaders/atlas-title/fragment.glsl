#version 300 es

precision highp float;

uniform sampler2D iChannel0;

in vec2 fragPos;
out vec4 fragColor;

float random (in vec2 _st) {
    return fract(sin(dot(_st.xy,vec2(12.9898,78.233)))*43758.5453123);
}

float sserp (float a0, float a1, float w) {
    return (a1 - a0) * ((w * (w * 6.0 - 15.0) + 10.0) * w * w * w) + a0;
}

void main() {
    vec2 uv = fragPos;
    fragColor = texture(iChannel0, fragPos);
}