
export class ParticleSimulation {
    delta_t: number
    substeps: number
    iterations: number
    max_r: number
    max_balls: number
    balls: number[][]
    colors: number[][]
    size: number
    vertexColor: Float32Array
    vertexPosition: Float32Array
    circleColor: Float32Array

    constructor(colors: number[][]) {
        this.delta_t = 0.1
        this.substeps = 4
        this.iterations = 4
        this.size = 500
        this.max_r = 0
        this.max_balls = 1100;
        this.balls = []
        this.colors = colors

        this.vertexPosition = new Float32Array(this.max_balls * 6);
        this.vertexColor = new Float32Array(this.max_balls * 6);
        this.circleColor = new Float32Array(this.max_balls * 9);
    }

    add_ball(x: number, y: number, r: number) {
        if (this.max_balls == this.balls.length) return;
        this.balls.push([x,y,x,y,r]);

        let ball = this.balls[this.balls.length-1];
        let pos = [ball[0]/this.size*2 - 1, ball[1]/this.size*2 - 1];


        let newVertexPos = [pos[0] + 1/this.size*4*ball[4], pos[1] + Math.sqrt(3)/2/this.size*4*ball[4], pos[0] - 1/this.size*4*ball[4], pos[1] + Math.sqrt(3)/2/this.size*4*ball[4], pos[0], pos[1] - Math.sqrt(3)/2/this.size*4*ball[4]]
        let newVertexColor = [1, 0, 0, 0, 0.5, 1];
        let newCircleColor = [this.colors[this.balls.length-1][0]/255, this.colors[this.balls.length-1][1]/255, this.colors[this.balls.length-1][2]/255, this.colors[this.balls.length-1][0]/255, this.colors[this.balls.length-1][1]/255, this.colors[this.balls.length-1][2]/255, this.colors[this.balls.length-1][0]/255, this.colors[this.balls.length-1][1]/255, this.colors[this.balls.length-1][2]/255];
        for (let j = 0; j < 9; j++) {
            if (j < 6) {
            this.vertexPosition[(this.balls.length-1)*6+j] = newVertexPos[j];
            this.vertexColor[(this.balls.length-1)*6+j] = newVertexColor[j];
            }
            this.circleColor[(this.balls.length-1)*9+j] = newCircleColor[j];
        }
    }

    draw_scene() {
        return [this.vertexPosition, this.vertexColor, this.circleColor];
    }

    update_position(dt: number) {
        for (let i = 0; i < this.balls.length; i++) {
            let ball = this.balls[i];
            let prev = [ball[0], ball[1]];
            ball[0] = 2*ball[0] - ball[2];
            ball[1] = 2*ball[1] - ball[3] - 9.8*dt*dt;
            ball[2] = prev[0];
            ball[3] = prev[1];

            let pos = [ball[0]/this.size*2 - 1, ball[1]/this.size*2 - 1];
            let newVertexPos = [pos[0] + 1/this.size*4*ball[4], pos[1] + Math.sqrt(3)/2/this.size*4*ball[4], pos[0] - 1/this.size*4*ball[4], pos[1] + Math.sqrt(3)/2/this.size*4*ball[4], pos[0], pos[1] - Math.sqrt(3)/2/this.size*4*ball[4]]
            for (let j = 0; j < 6; j++) this.vertexPosition[i*6+j] = newVertexPos[j];
        }
    }

    update_boundaries() {
        for (let i = 0; i < this.balls.length; i++) {
            let ball = this.balls[i];
            let dist = Math.hypot(ball[0]-this.size/2, ball[1]-this.size/2)+ball[4];
            if (dist > this.size/2) {
                ball[0] = (ball[0]-250)/dist*250+250
                ball[1] = (ball[1]-250)/dist*250+250
            }
            dist = Math.hypot(ball[2]-this.size/2, ball[3]-this.size/2)+ball[4];
            if (dist > this.size/2) {
                ball[2] = (ball[2]-250)/dist*250+250
                ball[3] = (ball[3]-250)/dist*250+250
            }
        }
    }

    update_collisions(i: number, j: number) {
        if (i <= j) return;
        let ball = this.balls[i];
        let other_ball = this.balls[j]
        let axis = [other_ball[0] - ball[0], other_ball[1] - ball[1]];
        let dist = axis[0]*axis[0] + axis[1]*axis[1];
        if (dist < (ball[4] + other_ball[4]) * (ball[4] + other_ball[4])) {
            let d_s = Math.sqrt(dist);
            let n = [axis[0] / d_s, axis[1] / d_s];
            let delta = ball[4] + other_ball[4] - d_s;

            other_ball[0] += delta * n[0] * 0.5
            other_ball[1] += delta * n[1] * 0.5
            ball[0] -= delta * n[0] * 0.5
            ball[1] -= delta * n[1] * 0.5
        }
    }

    check_cell_collision() {
        for (let i = 0; i < this.balls.length; i++) {
            for (let j = i+1; j < this.balls.length; j++) {
                if ((this.balls[i][0] - this.balls[j][0])*(this.balls[i][0] - this.balls[j][0])+(this.balls[i][1] - this.balls[j][1])*(this.balls[i][1] - this.balls[j][1]) < (this.balls[i][4] + this.balls[j][4]) * (this.balls[i][4] + this.balls[j][4])) {
                    this.update_collisions(j, i)
                }
            }
        }
    }

    update_mouse(dx: number, dy: number, dt: number) {
        for (let i = 0; i < this.balls.length; i++) {
            this.balls[i][0] += dx/20*dt;
            this.balls[i][1] -= dy/20*dt;
        }
    }

    update_physics(dx: number, dy: number) {
        for (let i = 0; i < this.substeps; i++) {
            this.update_mouse(dx, dy, this.delta_t/this.substeps);
            this.update_position(this.delta_t/this.substeps);
            for (let j = 0; j < this.iterations; j++) {
                this.check_cell_collision();
            }
        }
        this.update_boundaries();
    }
}