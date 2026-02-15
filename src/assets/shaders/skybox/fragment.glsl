#version 300 es
precision highp float;

uniform samplerCube skybox;
uniform mat4 proj;
uniform mat4 view;
uniform float time;
uniform float z_rot;
uniform float aspect_ratio;

in vec4 position;

out vec4 fragColor;

vec3 rotate(in vec3 p, vec3 r) {
    float a = r.x;
    float b = r.y;
    float y = r.z;
    return mat3(
        cos(a)*cos(b), cos(a)*sin(b)*sin(y)-sin(a)*cos(y), cos(a)*sin(b)*cos(y)+sin(a)*sin(y),
        sin(a)*cos(b), sin(a)*sin(b)*sin(y)+cos(a)*cos(y), sin(a)*sin(b)*cos(y)-cos(a)*sin(y),
        -sin(b), cos(b)*sin(y), cos(b)*cos(y)
     ) * p;
}

float random (in vec2 _st) {
    return fract(sin(dot(_st.xy,vec2(12.9898,78.233)))*43758.5453123);
}

vec3 random3 (in vec3 _st) {
    return rotate(vec3(1.0,0.0,0.0), vec3(random(_st.xy)*6.29, random(_st.yz)*6.29, random(_st.zx)*6.29));
}

float lerp (float a0, float a1, float w) {
    return (1.0-w) * a0 + w * a1;
}

float sserp (float a0, float a1, float w) {
    return (a1 - a0) * ((w * (w * 6.0 - 15.0) + 10.0) * w * w * w) + a0;
}

float genNoise(vec3 uv) {
    mat3 rounded = mat3(floor(uv), ceil(uv), vec3(0.0));
    float grad_x[2] = float[](0.0, 0.0);
    for (int i = 0; i < 2; i++) {
        float grad_y[2] = float[](0.0, 0.0);
        for (int j = 0; j < 2; j++) {
            vec3 grad_b = random3(vec3(rounded[i][0], rounded[j][1], rounded[0][2]));
            vec3 grad_t = random3(vec3(rounded[i][0], rounded[j][1], rounded[1][2]));
            vec3 to_b = vec3(uv - vec3(rounded[i][0], rounded[j][1], rounded[0][2]));
            vec3 to_t = vec3(uv - vec3(rounded[i][0], rounded[j][1], rounded[1][2]));
            grad_y[j] = sserp(dot(grad_b, to_b), dot(grad_t, to_t), fract(uv.z));
        }
        grad_x[i] = sserp(grad_y[0], grad_y[1], fract(uv.y));
    }

    return sserp(grad_x[0], grad_x[1], fract(uv.x)) + 0.5;
    
}

vec2 rotate(vec2 uv, float theta, float scale) {
    return (uv - scale/2.) * mat2(cos(theta), -sin(theta), sin(theta), cos(theta));
}

void main() {
    vec4 uv = position;

    vec4 t = inverse(proj * view) * uv;
    float v = genNoise(5.0*normalize(-t.xyz/t.w) + time/2.0);

    v = floor(v*7.0)/7.0;
    v *= 100.0;
    uv = (v < 45.0) ? uv : floor(uv*v)/v;
    t = inverse(proj * view) * uv;

    vec4 sky = texture(skybox, normalize(-t.xyz / t.w));
    fragColor = vec4((v > 45.0) ? floor(sky.x*20.0)/20.0 : sky.x, (v > 45.0) ? floor(sky.y*20.0)/20.0 : sky.y, (v > 45.0) ? floor(sky.z*20.0)/20.0 : sky.z, sky.w);
}