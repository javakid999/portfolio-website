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

float random (in vec2 _st) {
    return fract(sin(dot(_st.xy,vec2(12.9898,78.233)))*43758.5453123);
}

vec3 random3 (in vec3 _st) {
    return rotate(vec3(1.0,0.0,0.0), random(_st.xy)*6.29, random(_st.yz)*6.29, random(_st.zx)*6.29);
}

float sserp (float a0, float a1, float w) {
    return (a1 - a0) * ((w * (w * 6.0 - 15.0) + 10.0) * w * w * w) + a0;
}

float genNoise(vec3 uv) {

    vec3 xxx = floor(uv);
    vec3 oxx = vec3(floor(uv.x)+1.0, floor(uv.y), floor(uv.z));
    vec3 xox = vec3(floor(uv.x)    , floor(uv.y)+1.0, floor(uv.z));
    vec3 oox = vec3(floor(uv.x)+1.0, floor(uv.y)+1.0, floor(uv.z));
    vec3 xxo = vec3(floor(uv.x)    , floor(uv.y), floor(uv.z)+1.0);
    vec3 oxo = vec3(floor(uv.x)+1.0, floor(uv.y), floor(uv.z)+1.0);
    vec3 xoo = vec3(floor(uv.x)     ,floor(uv.y)+1.0, floor(uv.z)+1.0);
    vec3 ooo = ceil(uv);

    float x0 = sserp(dot(random3(xxx),uv - xxx),dot(random3(oxx),uv - oxx),fract(uv.x)); 
    float x1 = sserp(dot(random3(xox),uv - xox),dot(random3(oox),uv - oox),fract(uv.x)); 
    float x2 = sserp(dot(random3(xxo),uv - xxo),dot(random3(oxo),uv - oxo),fract(uv.x)); 
    float x3 = sserp(dot(random3(xoo),uv - xoo),dot(random3(ooo),uv - ooo),fract(uv.x)); 
    float y0 = sserp(x0,x1,fract(uv.y));
    float y1 = sserp(x2,x3,fract(uv.y));
    return sserp(y0,y1,fract(uv.z))+0.5;
}

vec4 sdTorus(vec3 p, vec2 t) {
    vec2 q = vec2(length(p.xz)-t.x,p.y);
    bool col = q.y > genNoise(p*2.0)/2.0-0.2;
    return vec4(col ? vec3(0.94,0.772,0.498) : vec3(1.0, 0.5, 0.6), length(q)-t.y);
}

vec4 world(vec3 p) {
    vec4 torus = sdTorus(rotate(p,iTime/2.0,0.0,iTime), vec2(1.5, 0.5));
    
    return torus;
}

vec3 calculate_normal(vec3 p) {
    const vec3 small_step = vec3(0.001, 0.0, 0.0);
    
    float grad_x = world(p + small_step.xyy).w - world(p - small_step.xyy).w;
    float grad_y = world(p + small_step.yxy).w - world(p - small_step.yxy).w;
    float grad_z = world(p + small_step.yyx).w - world(p - small_step.yyx).w;
    
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
        vec4 world = world(current_pos);
        vec3 col = world.xyz;
        float dist_closest = world.w;
        
        if (dist_closest < minh) {
            vec3 normal = calculate_normal(current_pos);
            vec3 light_dir = vec3(-1.0, 1.0, -1.0);
            
            float diffuse_intensity = max(0.0, dot(normal, normalize(light_dir)));
            vec3 ambient = vec3(0.15,0.1,0.2);
            
            return (diffuse_intensity)*col+ambient;
        }
        
        if (dist > maxh) {
            break;
        }
        
        dist += dist_closest;
    }
    
    return vec3(0.0);
}

vec3 bayer(vec3 col, vec2 uv, int res) {
    int num_cols = 7;
    vec3 col_aug = col + 0.25 * (texture(iChannel0, uv/8.0).xxx - 0.6);
    vec3 col_aug_clamp = max(min(col_aug, 0.99), 0.0);
    vec3 posterized = vec3(round(col_aug_clamp*float(num_cols))/float(num_cols));
    return posterized;
}

void main() {
    vec2 uv = fragPos * 2.0 - 1.0;
    
    vec3 camera_pos = vec3(0.0, 0.0, -2.5);
    vec3 ro = camera_pos;
    int res = int(14.0+5.9*sin(iTime/3.0));
    vec3 rd = vec3(floor(uv * float(res)) / float(res), 1.0);
    
    //vec3 color = bayer(ray_march(ro, rd), floor(uv * float(res)), res);
    vec3 actual_color = ray_march(ro, rd);
    vec3 bayer_color = bayer(actual_color, floor(uv * float(res)), res);

    int q_colors = 3;
    vec3 q = round(bayer_color*float(q_colors))/float(q_colors);
    vec3 h = round(clamp(length(bayer_color.xyz) == 0.0 ? bayer_color.xyz+0.58 : bayer_color.xyz * 1.5, 0.0, 1.0)*float(q_colors))/float(q_colors);
    float sum_c = (actual_color.x + actual_color.y + actual_color.z) / 3.0;
    float sum_q = (q.x + q.y + q.z) / 3.0;
    float sum_h = (h.x + h.y + h.z) / 3.0;

    float x = (sum_q == sum_h) ? 0.0 : floor((sum_c - sum_q)/(sum_h - sum_q)*10.0)/10.0;

    float ascii_val = texture(iChannel1, vec2(x+fract(uv.x*float(res))/10.0, 1.0-fract(uv.y*float(res)))).x;

    fragColor = vec4((ascii_val == 0.0) ? q : h, 1.0);
    
    //fragColor = vec4(color * texture(iChannel1, vec2(fract(fragPos.x * float(res*2)) / 10.0 + color.x, fract(-fragPos.y * float(res*2)))).xyz, 1.0);
    //fragColor = vec4(vec2(fract(fragPos.x * float(res*2)) / 2.0 + color.x, fract(-fragPos.y * float(res*2))/2.0), 0.0, 1.0);
    //fragColor = vec4(color, 1.0);
}