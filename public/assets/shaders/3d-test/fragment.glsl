#version 300 es

precision highp float;

in vec3 vColor;
out vec4 fragColor;

uniform float time;
uniform int selected;

void main() {
    float d = length(vColor.xy-0.5);
    if (d > 0.5) discard;
    //fragColor = vec4(1.0);
    fragColor = vec4((selected == 1) ? vec3(1.0) : vec3(0.7,1.0,1.0), d < 0.3 ? 1.0 : pow(0.5-d, 1.0+sin(time*0.5)*0.3)+0.3);
}