#version 300 es

precision highp float;

uniform float iTime;

in vec2 fragPos;
out vec4 fragColor;

float random (in vec2 _st) {
    return fract(sin(dot(_st.xy,vec2(12.9898,78.233)))*43758.5453123);
}

float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5*(a-b)/k, 0.0, 1.0);
    return mix(a, b, h) - k*h*(1.0-h);
}

float metaball(vec2 p, vec2 c, float r) {
    return clamp(r/pow(length(p-c),2.0),0.,1.0);
}

vec3 color(vec2 p) {
    float sum = 0.0;
    vec3 color_sum = vec3(0.0);
    int num = 300;
    for (int i = 0; i < num; i++) {
        float r1 = random(vec2(float(i  )/8.0));
        float r2 = random(vec2(float(i+1)/8.0));
        float r3 = random(vec2(float(i+2)/8.0));
        float r4 = random(vec2(float(i+3)/8.0));
        float r5 = random(vec2(float(i+4)/8.0));
        
        vec3 color = normalize(vec3(random(vec2(float(i+5)/8.0)), random(vec2(float(i+6)/8.0)), random(vec2(float(i+7)/8.0))));
        vec2 sphere_pos = vec2(r1 + sin(iTime/2.0+r2*6.28)/(r3+0.1)/4.0, r3 + cos(iTime/2.0+r4*6.28)/(r1+0.1)/4.0);
        float sphere = metaball(p, sphere_pos, r5/(5.0+3.0*sin(iTime/4.0))/float(num));
        sum += sphere;
        color_sum += color*10.0*clamp(sphere,0.0,0.1);
    }
    if (sum > 1.0) return normalize(color_sum*color_sum);
    return vec3(0.0);
}

void main()
{
    vec2 uv = fragPos;

    fragColor = vec4(color(uv),1.0);
}