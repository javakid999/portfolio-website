#version 300 es

precision highp float;

uniform float iTime;

in vec2 fragPos;
out vec4 fragColor;

vec3 hsv(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float map(float number, float inMin, float inMax, float outMin, float outMax) {
    return (number - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}

void main() {
    vec2 uv = fragPos;
    uv.x = (uv.x * 4.) - 2.5;
    uv.y = (uv.y * 4.) - 2.5;
    
    vec2 p = vec2(0.,0.);
    int n = 0;
    int m = 200;
    while(p.x * p.x + p.y * p.y <= 4. && n < m) {
        float xtemp = (p.x * p.x) - (p.y * p.y) + map(uv.x, -2., 2., -2. / pow(1.1,iTime), 2. / pow(1.1,iTime));
            p.y = 2. * p.x * p.y + map(uv.y, -1.12, 1.12, -1.12 / pow(1.1,iTime) + 1., 1.12 / pow(1.1,iTime) + 1.);
        p.x = xtemp;
        n++;
    }
    
    fragColor = vec4(hsv(vec3(float(n)/40.,1.,n<m)),1.0);
}