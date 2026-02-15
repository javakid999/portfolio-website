#version 300 es

in vec3 vertexPosition;
in vec3 vertexColor;

out vec3 vColor;

uniform mat4 view;
uniform mat4 proj;
uniform float time;

float random (in vec2 _st) {
    return fract(sin(dot(_st.xy,vec2(12.9898,78.233)))*43758.5453123);
}

void main() {
    gl_PointSize = 15.0;
    vec3 vertex_q = floor(vertexPosition*10.0)/10.0;
    vec4 r = vec4(
        sin(time*(random(vertex_q.yx)*1.5+0.5)+random(vertex_q.xy)*10.0)*0.01,
        sin(time*(random(vertex_q.zy)*1.5+0.5)+random(vertex_q.yz)*10.0)*0.01,
        sin(time*(random(vertex_q.xz)*1.5+0.5)+random(vertex_q.zx)*10.0)*0.01,
    0.0);
    gl_Position = proj * view * (vec4(vertexPosition, 1.0))+r;
    vColor = vertexColor;
}