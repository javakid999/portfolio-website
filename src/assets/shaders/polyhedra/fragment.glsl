#version 300 es

precision highp float;

uniform float iTime;
uniform int shape_num;
uniform float rot_factor;
uniform sampler2D iChannel0;

in vec2 fragPos;
out vec4 fragColor;

#define sabs(p) sqrt((p)*(p)+2e-3)
#define smin(a,b) (a+b-sabs(a-b))*.5
#define smax(a,b) (a+b+sabs(a-b))*.5

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

vec3 sserp3(vec3 a, vec3 b, float x) {
    return (b - a) * (x * x * x * (x * (6.0 * x - 15.0) + 10.0)) + a;
}

float sdTetrahedron(vec3 p)
{
    return (max(
	    abs(p.x+p.y)-p.z,
	    abs(p.x-p.y)+p.z
	)-1.)/sqrt(3.);
}

float sdIcosa(vec3 p,float r){
	float G=sqrt(5.)*.5+.5;
	vec3 n=normalize(vec3(G,1./G,0));
	float d=0.;
    p=sabs(p);
    d=smax(d,dot(p,n));
    d=smax(d,dot(p,n.yzx));
    d=smax(d,dot(p,n.zxy));
	d=smax(d,dot(p,normalize(vec3(1))));
    return d-r;
}

float sdDodecahedron(vec3 position, float radius, float cornerRadius) {
    position = abs(position);
    radius -= cornerRadius;
    float phi = (1.0 + sqrt(5.0)) * 0.5;
    float a = 1.0 / sqrt(3.0) * radius;
    float b = 1.0 / sqrt(3.0) * radius * (phi - 1.0);
    vec3 n1 = vec3(0.0, phi, 1.0) / sqrt(phi + 2.0);
    vec3 n2 = vec3(phi + 2.0, phi - 1.0, -1.0) / sqrt(4.0 * phi + 8.0); 
    vec3 n3 = vec3(phi, 1.0, 0.0) / sqrt(phi + 2.0);
    vec3 n4 = vec3(-1.0, phi, 3.0 - phi) / sqrt(12.0 - 4.0 * phi);
    vec3 p1 = position - vec3(0.0, a, 0.0);
    float h1 = dot(p1 - vec3(a, 0.0, a), n1);
    float m1 = dot(p1 - vec3(a, 0.0, a), n2);
    vec3 d1 = p1 - clamp(p1 - n1 * h1 - n2 * max(m1, 0.0), vec3(0.0), vec3(a, b, a)); 
    float h2 = dot(p1 - vec3(a, 0.0, a), n3);
    float m2 = dot(p1 - vec3(a, 0.0, a), n4);
    vec3 d2 = p1 - clamp(p1 - n3 * h2 - n4 * max(m2, 0.0), vec3(b, 0.0, 0.0), vec3(a, b, a));
    vec3 p2 = (position - vec3(a, 0.0, 0.0)).zxy;
    float h3 = dot(p2 - vec3(a, 0.0, a), n1);
    float m3 = dot(p2 - vec3(a, 0.0, a), n2);
    vec3 d3 = p2 - clamp(p2 - n1 * h3 - n2 * max(m3, 0.0), vec3(0.0), vec3(a, b, a)); 
    float h4 = dot(p2 - vec3(a, 0.0, a), n3);
    float m4 = dot(p2 - vec3(a, 0.0, a), n4);
    vec3 d4 = p2 - clamp(p2 - n3 * h4 - n4 * max(m4, 0.0), vec3(b, 0.0, 0.0), vec3(a, b, a));
    vec3 p3 = (position - vec3(0.0, 0.0, a)).yzx;
    float h5 = dot(p3 - vec3(a, 0.0, a), n1);
    float m5 = dot(p3 - vec3(a, 0.0, a), n2);
    vec3 d5 = p3 - clamp(p3 - n1 * h5 - n2 * max(m5, 0.0), vec3(0.0), vec3(a, b, a)); 
    float h6 = dot(p3 - vec3(a, 0.0, a), n3);
    float m6 = dot(p3 - vec3(a, 0.0, a), n4);
    vec3 d6 = p3 - clamp(p3 - n3 * h6 - n4 * max(m6, 0.0), vec3(b, 0.0, 0.0), vec3(a, b, a));
    float d = sqrt(min(min(min(min(min(dot(d1, d1), dot(d2, d2)), dot(d3, d3)), dot(d4, d4)), dot(d5, d5)), dot(d6, d6)));
    float s = max(max(max(max(max(h1, h2), h3), h4), h5), h6);
    return (s < 0.0 ? -d : d) - cornerRadius;
}
float world(vec3 p) {
    vec3 fastRot = vec3(1.0,0.0,2.0);
    vec3 slowRot = vec3(1.0/3.0,0.0,2.0/3.0);
    vec3 rot = sserp3(slowRot*mod(iTime, 6.0*3.141592), fastRot*mod(iTime, 6.0*3.141592), rot_factor);

    float shape;
    if (shape_num == 0) {
        shape = sdTetrahedron(rotate(p,rot));
    } else if (shape_num == 1) {
        shape = sdDodecahedron(rotate(p,rot), 1.5, 0.0);
    } else {
        shape = sdIcosa(rotate(p,rot), 1.5);
    }
    
    return shape;
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
            
            float diffuse_intensity = max(0.3, dot(normal, normalize(light_dir)));
            
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
    int num_cols = 8;
    vec3 col_aug = col + 0.3*(texture(iChannel0, fract(uv * float(res) / 8.0)).xxx - 0.9);
    vec3 diff;
    if (shape_num == 0) {
        diff = vec3(1.0,0.0,0.0);
    } else if (shape_num == 1) {
        diff = vec3(0.0, 1.0, 0.0);
    } else {
        diff = vec3(0.0, 1.0, 1.0);
    }
    vec3 col_aug_clamp = max(min(1.0, col_aug.x), 0.0) * diff;
    vec3 posterized = floor(col_aug_clamp*float(num_cols))/float(num_cols);
    return posterized;
}

void main() {
    vec2 uv = fragPos * 2.0 - 1.0;
    
    vec3 camera_pos = vec3(0.0, 0.0, -3.4);
    vec3 ro = camera_pos;
    int res = 15;
    vec3 rd = vec3(floor(uv * float(res)) / float(res), 1.0);
    
    vec3 color = bayer(ray_march(ro, rd), uv, res);
    
    fragColor = vec4(color,1.0);
}