#version 300 es

precision highp float;

in vec3 vColor;
out vec4 fragColor;

uniform float time;
uniform int id;
uniform float selected;

mat3 get_r(vec3 r) {
    float a = r.x;
    float b = r.y;
    float y = r.z;
    return mat3(
        cos(a)*cos(b), cos(a)*sin(b)*sin(y)-sin(a)*cos(y), cos(a)*sin(b)*cos(y)+sin(a)*sin(y),
        sin(a)*cos(b), sin(a)*sin(b)*sin(y)+cos(a)*cos(y), sin(a)*sin(b)*cos(y)-cos(a)*sin(y),
        -sin(b), cos(b)*sin(y), cos(b)*cos(y)
    );
}

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

struct Cube {
    vec3 center;
    vec3 size;
    mat3 model;
    float ior;
};

struct Intersect {
    bool hit;
    float t_enter;
    float t_exit;
    vec3 normal;
};

float random (in vec2 _st) {
    return fract(sin(dot(_st.xy,vec2(12.9898,78.233)))*43758.5453123);
}

vec3 random3 (in vec3 _st) {
    return rotate(vec3(1.0,0.0,0.0), vec3(random(_st.xy)*6.29, random(_st.yz)*6.29, random(_st.zx)*6.29));
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

vec3 sserp3(vec3 a, vec3 b, float x) {
    return (b - a) * (x * x * x * (x * (6.0 * x - 15.0) + 10.0)) + a;
}

vec3 lerp3(vec3 a, vec3 b, float x) {
    return (b - a) * x + a;
}

vec3 gradient(vec3 col0, vec4 col1, vec3 col2, float x) {
    return (x<col1.w) ? lerp3(col0,col1.xyz,x/col1.w) : lerp3(col1.xyz,col2, (x-col1.w)/(1.0-col1.w));
}

float fbm(vec3 uv, float scale, int octaves) {
    float sum = 0.;
    float contribution = 0.5;
    for (int i = 0; i < octaves; i++) {
        sum += genNoise(uv*scale) * contribution;
        scale *= 2.;
        contribution *= 0.5;
        uv = rotate(uv, vec3(1.3*float(i), 1.0*float(i), 0.3*float(i)));
    }
    return clamp(sum, 0.0, 1.0);
}

Intersect ray_cube(vec3 ro, vec3 rd, Cube c) {
    ro = inverse(c.model) * ro;
    rd = inverse(c.model) * rd;
    vec3 b = c.center - c.size;
    vec3 t = c.center + c.size;
    vec3 t1 = (b - ro) / rd;
    vec3 t2 = (t - ro) / rd;
    
    float te = max(max(min(t1.x, t2.x), min(t1.y, t2.y)), min(t1.z, t2.z));
    float tl = min(min(max(t1.x, t2.x), max(t1.y, t2.y)), max(t1.z, t2.z));
    
    if (te > tl || tl <= 0.0) {
        return Intersect(false, te, tl, vec3(0.0));
    } else {
        vec3 p = (ro+rd*te) - c.center;
        vec3 n = p/c.size;
        vec3 n_abs = abs(n);
        if (n_abs.x > n_abs.y && n_abs.x > n_abs.z) n = vec3(sign(n.x), 0.0, 0.0);
        else if (n_abs.y > n_abs.x && n_abs.y > n_abs.z) n = vec3(0.0, sign(n.y), 0.0);
        else n = vec3(0.0, 0.0, sign(n.z));
        
        return Intersect(true, te, tl, inverse(transpose(c.model)) * n);
    }
}

float sdBox( vec3 p, vec3 b)
{
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

vec4 ray_trace(vec3 ro, vec3 rd) {
    Cube c1 = Cube(
        vec3(0.0, 0.0, 0.0),
        vec3(1.0, 1.0, 1.0),
        get_r(vec3(time*0.84+float(id)*3.0, -time*0.6+float(id)*3.0, 0)),
        sserp(1.06, 1.1, selected)
    );
    mat3 inv = inverse(c1.model);

    Intersect isect = ray_cube(ro, rd, c1);
    
    if (isect.hit)  {
        float c = 0.0;
        vec4 final_color = vec4(0.0);
        float dist = (isect.t_exit - isect.t_enter);
        int steps = int(dist * 30.0);
        
        float n = 1.0/c1.ior;
        float cos_theta = dot(-isect.normal,rd);
        float discriminant = 1.0 - (n*n) * (1.0 - cos_theta*cos_theta);
        
        vec3 rd_ref = n * rd + (n*cos_theta - sqrt(discriminant)) * isect.normal;
        for (int i = 0; i < steps; i++) {
            vec3 p = (inv * ro) + (inv * rd_ref) * (isect.t_enter + float(i)/float(steps) * dist);
            float edge_dist = max(max(abs(p.x - c1.center.x), abs(p.y - c1.center.y)), abs(p.z - c1.center.z));
            float glow_factor = sserp(0.8, 0.6, selected);
            if (edge_dist > glow_factor) {
                final_color += vec4(vec3(0.1 * (edge_dist - glow_factor)), (edge_dist - glow_factor)*0.4);
            }
            p = floor(p*20.0)*0.05;
            float noise = fbm(p + float(id) * 3.0 + vec3(time/3.0, 0.0, 0.0), 1.3, 5);
            if (noise > 0.6) {
                if (random(p.xy * p.yz) > 0.99) {
                    final_color += vec4(0.5, 0.7, 0.1, 0.1);
                }
            }
            c += pow(noise*1.05, 7.0) * 0.2;
        }
        
        final_color += vec4(gradient(vec3(0.0, 0.28, 0.45), vec4(0.219, 1.0, 0.7372, 0.4), vec3(1.0), c), clamp(c, sserp(0.3, 0.7, selected), 1.0));
        return final_color;
    }
    
    vec3 p1 = inv * ro + inv * rd * isect.t_enter;
    vec3 p2 = inv * ro + inv * rd * isect.t_exit;
    vec3 cmin = c1.center - c1.size;
    vec3 cmax = c1.center + c1.size;
    float closest = min(
        length(p1 -
            vec3(clamp(p1.x, cmin.x, cmax.x),
                 clamp(p1.y, cmin.y, cmax.y),
                 clamp(p1.z, cmin.z, cmax.z))
        ),
        length(p2 -
            vec3(clamp(p2.x, cmin.x, cmax.x),
                 clamp(p2.y, cmin.y, cmax.y),
                 clamp(p2.z, cmin.z, cmax.z))
        )
    );
    if (closest < 0.3) {
        return vec4(vec3(0.1, 0.38, 0.55) * 4.0, (0.3-closest));
    }

    discard;
}

void main() {
    vec2 uv = vColor.xy * 2.0 - 1.0;

    vec3 ro = vec3(0.0, 0.0, -3.0);
    vec3 rd = normalize(vec3(uv, 1.0));
    
    vec4 color = ray_trace(ro, rd);
    
    fragColor = vec4(color);
}