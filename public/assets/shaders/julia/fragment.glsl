#version 300 es

precision highp float;

uniform float iTime;

in vec2 fragPos;
out vec4 fragColor;

#define PI 3.141592653598

vec3 hsv(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float atan2(float y, float x) {
    bool s = (abs(x) > abs(y));
    return mix(PI/2.0 - atan(x,y), atan(y,x), s);
}

float map(float number, float inMin, float inMax, float outMin, float outMax) {
    return (number - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}

vec2 complexPower(float power, vec2 n) {
    float r = length(n);
    float t = atan2(n.y,n.x);
    return vec2(pow(r, power) * cos(power * t), pow(r, power) * sin(power * t));
}

void main() {
    vec2 uv = fragPos;
    uv = (uv * 4.) - 2.0;
    
    vec2 z = uv;
    float num = 3.0+round(1.45*sin(iTime/10.0));
    vec2 c = vec2(0.7*sin(iTime/4.0), 0.7*cos(iTime/4.2));
    int n = 0;
    int m = 200;
    while(z.x * z.x + z.y * z.y <= 4. && n < m) {
        z = complexPower(num, z) + c;
        n++;
    }
    
    fragColor = vec4(hsv(vec3(100.0-float(n)/40.,1.,n<m)),1.0);
}