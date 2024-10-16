#version 300 es

precision highp float;

uniform float iTime;
uniform sampler2D iChannel0;

in vec2 fragPos;
out vec4 fragColor;

float sdTri(  in vec2 p, in float r ) {
    const float k = sqrt(3.0);
    p.x = abs(p.x) - r;
    p.y = p.y + r/k;
    if( p.x+k*p.y>0.0 ) p=vec2(p.x-k*p.y,-k*p.x-p.y)/2.0;
    p.x -= clamp( p.x, -2.0*r, 0.0 );
    return -length(p)*sign(p.y);
}
vec2 reflectAngle(vec2 uv, float angle) {
    vec2 n = vec2(sin(angle), cos(angle));
    float d = dot(uv, n);
    
    uv -= n*min(0., d)*2.0;
    return uv;
}
float atan2(in float y, in float x) {
    return x == 0.0 ? sign(y)*3.141592653/2.0 : atan(y, x);
}
vec4 hsv(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return vec4(c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y), 1.0);
}
vec2 rotate(vec2 uv, float theta) {
    return (uv) * mat2(cos(theta), -sin(theta), sin(theta), cos(theta));
}
vec4 bayer(vec4 col, vec2 uv, float depth, float contrast, float rotation) {
    return (round((col+contrast*vec4(texture(iChannel0, mod(rotate(uv, rotation),8.0)).x-0.5))*pow(2.0, depth)))/pow(2.0, depth);
}
float map(float number, float inMin, float inMax, float outMin, float outMax) {
    return (number - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}

float random (in vec2 _st) {
    return fract(sin(dot(_st.xy,vec2(12.9898,78.233)))*43758.5453123);
}
float sserp (float a0, float a1, float w) {
    return (a1 - a0) * ((w * (w * 6.0 - 15.0) + 10.0) * w * w * w) + a0;
}
float genNoise(vec2 uv) {
    vec2 TL = floor(uv);
    vec2 TR = vec2(ceil(uv.x), floor(uv.y));
    vec2 BL = vec2(floor(uv.x), ceil(uv.y));
    vec2 BR = ceil(uv);
    
    vec2 gradTL = vec2( cos(random(TL) * 6.283), sin(random(TL) * 6.283) );
    vec2 toTL = vec2( uv.x  - TL.x, uv.y - TL.y );
    vec2 gradTR = vec2( cos(random(TR) * 6.283), sin(random(TR) * 6.283) );
    vec2 toTR = vec2( uv.x  - TR.x, uv.y - TR.y );
    
    vec2 gradBL = vec2( cos(random(BL) * 6.283), sin(random(BL) * 6.283) );
    vec2 toBL = vec2( uv.x  - BL.x, uv.y - BL.y );
    vec2 gradBR = vec2( cos(random(BR) * 6.283), sin(random(BR) * 6.283) );
    vec2 toBR = vec2( uv.x  - BR.x, uv.y - BR.y );
    
    float t = sserp(dot(gradTL,toTL),dot(gradTR,toTR),fract(uv).x); 
    float b = sserp(dot(gradBL,toBL),dot(gradBR,toBR),fract(uv).x);
    return sserp(t,b,fract(uv).y) + 0.5;
}

vec2 rotateScale(vec2 uv, float theta, float scale) {
    return (uv - scale/2.) * mat2(cos(theta), -sin(theta), sin(theta), cos(theta));
}

float fbm(vec2 uv, int octaves) {
    float sum = 0.;
    float contribution = 0.5;
    float scale = 1.;
    for (int i = 0; i < octaves; i++) {
        sum += genNoise(uv*scale) * contribution;
        scale *= 2.;
        contribution *= 0.5;
        uv = rotateScale(uv, 1.2, scale);
    }
    return sum;
}

void main() {
    float pi = 3.1415926535;
    vec2 uv = fragPos - 0.5;
    uv *= 2.0;
    vec2 pos = vec2(1.0/7.0, sqrt(3.0)/14.0);
    float time = min(mod(iTime-2.0,6.0)+2.0,iTime);
    uv.x = sserp(map(uv.x, -1.0, 1.0, -1.0/pow(3.0, time), 1.0/pow(3.0, time)),  map(uv.x, -1.0, 1.0, -1.0/pow(3.0, time) + pos.x, 1.0/pow(3.0, time) + pos.x), min(iTime/2.0, 1.0));
    uv.y = sserp(map(uv.y, -1.0, 1.0, -1.0/pow(3.0, time) - 0.25, 1.0/pow(3.0, time) - 0.25), map(uv.y, -1.0, 1.0, -1.0/pow(3.0, time) + pos.y, 1.0/pow(3.0, time) + pos.y), min(iTime/2.0, 1.0));
    vec3 col = vec3(0.0);

    if (sdTri(uv, 0.5) < 0.0) {
        col = vec3(1.0);
    }
    
    uv = reflectAngle(uv, pi/2.0);
    uv.x *= -1.0;
    uv.x += 0.5;
    uv = reflectAngle(uv, pi/6.0);
    for (int i = 0; i < 20; i++) {
        uv *= 3.0;
        uv.x -= 1.5;
    
        uv.x = abs(uv.x);
        uv.x -= 0.5;
        uv = reflectAngle(uv, 2.0*pi/3.0);
    }
    uv = reflectAngle(uv/10.0, 4.6);
    if (uv.y < 0.1) {
        fragColor = vec4(1.0,1.0,1.0,1.0);
    } else {
        float rot = pi+1.0+iTime*pi/3.0;
        float thetaWeird = atan2(uv.y,uv.x);
        uv = fragPos-0.5;
        uv *= 30.0;
        uv = rotate(uv, rot);
        float theta = atan2(uv.y,uv.x);
        vec2 uvNoise = fragPos - 0.5;
        uvNoise *= 3.0;
        uvNoise *= (sin(thetaWeird)-pi)/(length(uvNoise)-0.2);
        uvNoise = rotate(uvNoise, rot);
        float noise = fbm(uvNoise, 2);
        vec4 col = bayer(hsv(vec3(iTime/10.0, 1.0, min(iTime/4.0,1.0)*noise*3.0*map(length(uv) < 1.3 ? -1.0 : theta, -pi, pi, 0.5, -0.1))), uv, 2.0, 0.9, -rot/1.2);
        fragColor = col;
        //fragColor = texture(iChannel0, fragPos);
    }
}