#version 300 es

precision highp float;

uniform float iTime;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;

in vec2 fragPos;
out vec4 fragColor;

vec3 rotate(in vec3 p, float a, float b, float y) {
    return mat3(
        cos(a)*cos(b), cos(a)*sin(b)*sin(y)-sin(a)*cos(y), cos(a)*sin(b)*cos(y)+sin(a)*sin(y),
        sin(a)*cos(b), sin(a)*sin(b)*sin(y)+cos(a)*cos(y), sin(a)*sin(b)*cos(y)-cos(a)*sin(y),
        -sin(b), cos(b)*sin(y), cos(b)*cos(y)
     ) * p;
}

float sdTorus(vec3 p, vec2 t) {
    vec3 pt = rotate(p,0.0,iTime/2.0,iTime);
    vec2 q = vec2(length(pt.xz)-t.x,pt.y);
    return length(q)-t.y;
}

float world(vec3 p) {
    float torus = sdTorus(p, vec2(1.5, 0.5));
    
    return torus;
}

vec3 calculate_normal(vec3 p) {
    const vec3 small_step = vec3(0.001, 0.0, 0.0);
    
    float grad_x = world(p + small_step.xyy) - world(p - small_step.xyy);
    float grad_y = world(p + small_step.yxy) - world(p - small_step.yxy);
    float grad_z = world(p + small_step.yyx) - world(p - small_step.yyx);
    
    vec3 normal = vec3(grad_x, grad_y, grad_z);
    
    return normalize(normal);
}

vec3 ray_march(vec3 ro, vec3 rd) {
    float dist = 0.0;
    const int nsteps = 64;
    const float minh = 0.01;
    const float maxh = 1000.0;
    
    for (int i = 0; i < nsteps; i++) {
        vec3 current_pos = ro + dist * rd;
        float dist_closest = world(current_pos);
        
        if (dist_closest < minh) {
            vec3 normal = calculate_normal(current_pos);
            vec3 light_dir = vec3(-1.0, 1.0, -1.0);
            
            float diffuse_intensity = max(0.2, dot(normal, normalize(light_dir)));
            
            return vec3(diffuse_intensity);
        }
        
        if (dist > maxh) {
            break;
        }
        
        dist += dist_closest;
    }
    
    return vec3(0.0);
}

vec3 bayer(vec3 col, vec2 uv, int res) {
    int num_cols = 6;
    vec3 col_aug = col.x + 0.3 * (texture(iChannel0, uv/8.0).xxx - 0.5);
    float col_aug_clamp = max(min(col_aug.x, 0.99), 0.0);
    vec3 posterized = vec3(floor(col_aug_clamp*float(num_cols))/float(num_cols));
    return posterized;
}

void main() {
    vec2 uv = fragPos * 2.0 - 1.0;
    
    vec3 camera_pos = vec3(0.0, 0.0, -2.5);
    vec3 ro = camera_pos;
    int res = int(14.0+5.9*sin(iTime/3.0));
    vec3 rd = vec3(floor(uv * float(res)) / float(res), 1.0);
    
    vec3 color = bayer(ray_march(ro, rd), floor(uv * float(res)), res);
    
    fragColor = texture(iChannel1, vec2(fract(fragPos.x * float(res*2)) / 6.0 + color.x, fract(-fragPos.y * float(res*2))));
    //fragColor = vec4(vec2(fract(fragPos.x * float(res*2)) / 2.0 + color.x, fract(-fragPos.y * float(res*2))/2.0), 0.0, 1.0);
    //fragColor = vec4(color, 1.0);
}