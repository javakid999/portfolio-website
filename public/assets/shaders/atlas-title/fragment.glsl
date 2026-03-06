#version 300 es

precision highp float;

uniform sampler2D iChannel0;

uniform float time;

in vec2 fragPos;
out vec4 fragColor;

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
    return sserp(t,b,fract(uv).y);
}


void main() {
    vec2 uv = fragPos;
    fragColor = texture(iChannel0, uv+genNoise(uv*2.0+time)*0.03 + sin(time)*0.05*vec2(0.0, random(vec2(floor((uv.x+time/20.0)*200.0)/200.0, 0))));
}