#version 300 es
#define TITLE_SIZE 16
#define TILEMAP_COLS 16.0
#define TILEMAP_ROWS 5.0


precision highp float;

in vec3 vColor;
out vec4 fragColor;

uniform sampler2D tilemap;
int chars[TITLE_SIZE] = int[](7, 16+14, 32+5, 32+5, 32+8, 64+4, 64+0, 64+1, 64+2, 64+3, 34, 21, 65, 13, 9, 3);

void main() {
    vec2 uv = vColor.xy;
    int c = int(uv.x*float(TITLE_SIZE));
    uv.x = fract(uv.x*float(TITLE_SIZE));
    uv /= vec2(TILEMAP_COLS, TILEMAP_ROWS);
    
    uv.x += (1.0/TILEMAP_COLS * float(chars[c] % int(TILEMAP_COLS)));
    uv.y += (1.0/TILEMAP_ROWS * float(chars[c] / int(TILEMAP_COLS)));

    fragColor = texture(tilemap, uv);
}