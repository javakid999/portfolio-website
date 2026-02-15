let lerp = (a: number[], b: number[], x: number) => {
    let c = []
    for (let i = 0; i < a.length; i++) {
        c.push((1-x)*a[i] + x*b[i]);
    }
    return c;
}

export function generateIcosphere(): [Float32Array, Float32Array, number[][]] {
    const vertex_pos: number[]   = [];
    const vertex_color: number[] = [];

    const phi = (1 + Math.sqrt(5))/2
    
    const radius = 1;
    const subdivisions = 3;
    const color = [0,0,1]

    const a = radius / Math.sqrt(1 + phi)
    const c = radius * phi / Math.sqrt(1 + phi)

    // Base icosahedron
    const points = [
        [a, c, 0],  [a, -c, 0],  [-a, -c, 0],  [-a, c, 0],
        [0, a, c],  [0, a, -c],  [0, -a, -c],  [0, -a, c],
        [c, 0, a],  [-c, 0, a],  [-c, 0, -a],  [c, 0, -a],
    ]

    for (let p = 0; p < points.length; p++) {
        const point = points[p];

        // p[2]z=-p[1]y-p[0]x
        // (p[0]x, p[1]y, (-p[1]y-p[0]x)/p[2])
        // b_1 = (p[0], 0, -p[0]/p[2])
        // b_2 = (0, p[1], -p[1]/p[2])

        let b_1: number[];
        let b_2: number[];

        if (point[0] == 0) {
            b_1 = [1, 0, 0];
            b_2 = [0, -point[2], point[1]];
        } else if (point[1] == 0) {
            b_1 = [0, 1, 0];
            b_2 = [-point[2], 0, point[0]];
        } else {
            b_1 = [0, 0, 1];
            b_2 = [-point[1], point[0], 0];
        }

        let b_1_len = Math.hypot(...b_1)
        let b_2_len = Math.hypot(...b_2)
        b_1 = b_1.map(x => x / b_1_len);
        b_2 = b_2.map(x => x / b_2_len);

        const tri: number[][] = [
            [point[0]+(b_1[0]+b_2[0])*0.2,  point[1]+(b_1[1]+b_2[1])*0.2,  point[2]+(b_1[2]+b_2[2])*0.2],
            [point[0]+(-b_1[0]+b_2[0])*0.2, point[1]+(-b_1[1]+b_2[1])*0.2, point[2]+(-b_1[2]+b_2[2])*0.2],
            [point[0]+(b_1[0]-b_2[0])*0.2,  point[1]+(b_1[1]-b_2[1])*0.2,  point[2]+(b_1[2]-b_2[2])*0.2],
            [point[0]+(-b_1[0]-b_2[0])*0.2, point[1]+(-b_1[1]-b_2[1])*0.2, point[2]+(-b_1[2]-b_2[2])*0.2],
        ]
        vertex_pos.push(...tri[0], ...tri[1], ...tri[3], ...tri[0], ...tri[3], ...tri[2])
        vertex_color.push(...[1,1,0], ...[0,1,0], ...[0,0,0], ...[1,1,0], ...[0,0,0], ...[1,0,0])
    }

    return [new Float32Array(vertex_pos), new Float32Array(vertex_color), points];
}