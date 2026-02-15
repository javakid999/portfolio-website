import { mat4 } from "gl-matrix";
import { generateIcosphere } from "./atlas/icophere";
import { CanvasManager } from "./canvasManager";
import { ParticleSimulation } from "./particleSimulation";

export class Canvas {
    element: HTMLCanvasElement;
    gl: WebGL2RenderingContext;
    programs: {[name: string]: Program};
    global_attributes: {[name: string]: Attribute};
    draw_calls: DrawCall[];
    clear_color: [number, number, number, number] = [0,0,0,1]

    program_vertex_data: {[program: string]: [string, Float32Array]};

    constructor(element: HTMLCanvasElement, width: number, height: number) {
        this.element = element;
        this.element.width = width;
        this.element.height = height;
        this.gl = element.getContext('webgl2')!;
        this.programs = {};
        this.program_vertex_data = {};
        this.global_attributes = {};
        this.draw_calls = [];

        this.initCanvas()
    }

    private initCanvas() {
        this.gl.viewport(0, 0, this.element.width, this.element.height);
        this.gl.enable(this.gl.DEPTH_TEST);
        this.gl.enable(this.gl.BLEND);
        this.gl.blendFunc(this.gl.SRC_ALPHA, this.gl.ONE_MINUS_SRC_ALPHA)
        this.clearCanvas();
    }

    private compileShader(src: string, type: GLenum): WebGLShader | null {
        const shader = this.gl.createShader(type)!;
        this.gl.shaderSource(shader, src);
        this.gl.compileShader(shader);
        const status = this.gl.getShaderParameter(shader, this.gl.COMPILE_STATUS);
        console.log(this.gl.getShaderInfoLog(shader));
        if (status) {
            return shader;
        } else {
            console.log(this.gl.getShaderInfoLog(shader));
            this.gl.deleteShader(shader);
            return null;
        }
    }

    compileProgram(name: string, vsrc: string, fsrc: string) {
        const vertex = this.compileShader(vsrc, this.gl.VERTEX_SHADER)!;
        const fragment = this.compileShader(fsrc, this.gl.FRAGMENT_SHADER)!;
        const gl_program = this.gl.createProgram()!;

        this.gl.attachShader(gl_program, vertex);
        this.gl.attachShader(gl_program, fragment);
        this.gl.linkProgram(gl_program);

        const status = this.gl.getProgramParameter(gl_program, this.gl.LINK_STATUS);
        console.log(this.gl.getProgramInfoLog(gl_program));

        if (status) {
            const program: Program = {
                name: name,
                program: gl_program,
                vao: this.gl.createVertexArray(),
                attributes: {},
                uniforms: {},
                frame_buffers: {}
            };
            this.programs[name] = program;
        } else {
            this.gl.deleteProgram(gl_program)
        }
    }

    addFrameBuffer(name: string, program_name: string, width: number, height: number, render_buffers: RenderBuffer[], texture_types: number[]) {
        this.gl.useProgram(this.programs[program_name].program);

        // Create framebuffer
        const frame_buffer = this.gl.createFramebuffer();
        this.gl.bindFramebuffer(this.gl.FRAMEBUFFER, frame_buffer)
        this.gl.viewport(0, 0, this.element.width, this.element.height);

        // Create RenderBuffers, bind to framebuffer
        for (let i = 0; i < render_buffers.length; i++) {
            const render_buffer = this.gl.createRenderbuffer();
            this.gl.bindRenderbuffer(this.gl.RENDERBUFFER, render_buffer)
            this.gl.renderbufferStorage(this.gl.RENDERBUFFER, render_buffers[i].internal_format, width, height)
            this.gl.framebufferRenderbuffer(this.gl.FRAMEBUFFER, render_buffers[i].attachment, this.gl.RENDERBUFFER, render_buffer)
        }

        // Create textures, bind to framebuffer
        for (let i = 0; i < texture_types.length; i++) {
            const texture = this.gl.createTexture();
            this.gl.bindTexture(this.gl.TEXTURE_2D, texture)
            this.gl.texParameteri(this.gl.TEXTURE_2D, this.gl.TEXTURE_MIN_FILTER, this.gl.LINEAR);
            this.gl.texParameteri(this.gl.TEXTURE_2D, this.gl.TEXTURE_WRAP_S, this.gl.CLAMP_TO_EDGE);
            this.gl.texParameteri(this.gl.TEXTURE_2D, this.gl.TEXTURE_WRAP_T, this.gl.CLAMP_TO_EDGE);
            this.gl.texImage2D(this.gl.TEXTURE_2D, 0, this.gl.RGBA, width, height, 0, this.gl.RGBA, this.gl.UNSIGNED_BYTE, null);
            this.gl.framebufferTexture2D(this.gl.FRAMEBUFFER, texture_types[i], this.gl.TEXTURE_2D, texture, 0);
        }

        this.programs[program_name].frame_buffers[name] = {
            frame_buffer: frame_buffer,
            size: [width, height],
            render_buffers: render_buffers,
            texture_types: texture_types
        }

        this.gl.bindFramebuffer(this.gl.FRAMEBUFFER, null)
    }

    addAttribute(name: string, program_name: string, size: number, type: GLenum, normalize: boolean, stride: number, offset: number, bufferType: GLenum, isVertexData: boolean) {
        const attributeLocation = this.gl.getAttribLocation(this.programs[program_name].program, name);
        this.programs[program_name].attributes[name] = {name: name, buffer: this.gl.createBuffer()!, location: attributeLocation, size: size, type: type, normalize: normalize, stride: stride, offset: offset, bufferType: bufferType, isVertexData: isVertexData};
        
        this.gl.useProgram(this.programs[program_name].program);

        this.gl.bindBuffer(bufferType, this.programs[program_name].attributes[name].buffer);
        this.gl.bindVertexArray(this.programs[program_name].vao);
        this.gl.enableVertexAttribArray(attributeLocation);
        this.gl.vertexAttribPointer(attributeLocation, size, type, normalize, stride, offset);
        this.gl.bindVertexArray(null);
    }

    attributeData(name: string, program_name: string, data: Float32Array) {
        this.gl.useProgram(this.programs[program_name].program);

        if (this.programs[program_name].attributes[name].isVertexData) {
            this.program_vertex_data[program_name] = [name, data];
        } else {
            this.gl.bindBuffer(this.programs[program_name].attributes[name].bufferType, this.programs[program_name].attributes[name].buffer);
            this.gl.bufferData(this.programs[program_name].attributes[name].bufferType, data, this.gl.STATIC_DRAW);
        }
        //Attribute Data DrawLength: Math.floor((data.length - this.programs[program_name].attributes[name].offset) / this.programs[program_name].attributes[name].size / (this.programs[program_name].attributes[name].stride == 0 ? 1 : this.programs[program_name].attributes[name].stride));
    }

    addUniform(name: string, program_name: string, type: UniformType, length: number) {
        this.gl.useProgram(this.programs[program_name].program)
        const uniformLocation = this.gl.getUniformLocation(this.programs[program_name].program, name)!;
        this.programs[program_name].uniforms[name] = {name: name, location: uniformLocation, type: type, length: length}
    }

    getDrawLength(program_name: string) {
        const attrib_size = this.programs[program_name].attributes[this.program_vertex_data[program_name][0]].size;
        return this.program_vertex_data[program_name][1].length / attrib_size;
    }

    getPixel(program_name: string, x: number, y: number, frame_buffer?: string): Uint8Array {
        this.gl.useProgram(this.programs[program_name].program);

        if (frame_buffer) {
            this.gl.bindFramebuffer(this.gl.FRAMEBUFFER, this.programs[program_name].frame_buffers[frame_buffer].frame_buffer);
        } else {
            this.gl.bindFramebuffer(this.gl.FRAMEBUFFER, null);
        }

        const data = new Uint8Array(4);
        this.gl.readPixels(x, y, 1, 1, this.gl.RGBA, this.gl.UNSIGNED_BYTE, data);

        this.gl.bindFramebuffer(this.gl.FRAMEBUFFER, null)

        return data;
    }

    addDrawCall(program_name: string, draw_length: number, offset: number, z_layer: number, frame_buffers?: string[], options?: DrawCallOptions, pre_draw?: (c: Canvas) => void) {
        const draw_call: DrawCall = {
            program: this.programs[program_name],
            drawLength: draw_length,
            offset: offset,
            z_layer: z_layer,
            frame_buffers: frame_buffers? frame_buffers : [],
            options: options,
            pre_draw: pre_draw
        };
        this.draw_calls.push(draw_call);
        this.draw_calls.sort((a, b) => a.z_layer- b.z_layer)
    }

    clearDrawCalls(program_name?: string) {
        if (program_name !== undefined) {
            this.draw_calls = this.draw_calls.filter((d) => d.program.name !== program_name);
        } else {
            this.draw_calls = [];
        }
    }

    uniformData(name: string, program_name: string, data: number | Float32Array | Int32Array | mat4): void;
    uniformData(name: string, program_name: string, data: number, image: HTMLImageElement | HTMLImageElement[]): void;
    uniformData(name: string, program_name: string, data: number | Float32Array | Int32Array | mat4, image?: HTMLImageElement | HTMLImageElement[]): void {
        this.gl.useProgram(this.programs[program_name].program);

        switch(this.programs[program_name].uniforms[name].type) {
            case UniformType.Float:
                switch(this.programs[program_name].uniforms[name].length) {
                    case 1:
                        if (typeof data === "number") {
                            this.gl.uniform1f(this.programs[program_name].uniforms[name].location, data);
                        }
                        break;
                }
                break;
                // todo: arrays of floats
            case UniformType.FloatArray:
            case UniformType.FloatVector:
            case UniformType.Integer:
                switch(this.programs[program_name].uniforms[name].length) {
                    case 1:
                        if (typeof data === 'number') {
                            this.gl.uniform1i(this.programs[program_name].uniforms[name].location, data);
                        }
                        break;
                }
                break;
                // todo: arrays of ints
            case UniformType.IntegerArray:
            case UniformType.IntegerVector:
            case UniformType.Matrix2:
            case UniformType.Matrix3:
            case UniformType.Matrix4:
                if (typeof data !== 'number' && typeof data[Symbol.iterator] === 'function') {
                    this.gl.uniformMatrix4fv(this.programs[program_name].uniforms[name].location, false, data);
                }
            case UniformType.Texture2D:
                if (image != undefined && typeof data === 'number' && !Array.isArray(image)) {
                    const texture = this.gl.createTexture()!;
                    this.gl.activeTexture(this.gl.TEXTURE0 + data);
                    this.gl.bindTexture(this.gl.TEXTURE_2D, texture);

                    // i need to allow changing the settings here later
                    this.gl.texParameteri(this.gl.TEXTURE_2D, this.gl.TEXTURE_WRAP_S, this.gl.REPEAT);
                    this.gl.texParameteri(this.gl.TEXTURE_2D, this.gl.TEXTURE_WRAP_T, this.gl.REPEAT);
                    this.gl.texParameteri(this.gl.TEXTURE_2D, this.gl.TEXTURE_MIN_FILTER, this.gl.NEAREST);
                    this.gl.texParameteri(this.gl.TEXTURE_2D, this.gl.TEXTURE_MAG_FILTER, this.gl.NEAREST);

                    this.gl.texImage2D(this.gl.TEXTURE_2D, 0, this.gl.RGBA, image.width, image.height, 0, this.gl.RGBA, this.gl.UNSIGNED_BYTE, image!);
                    this.gl.uniform1i(this.programs[program_name].uniforms[name].location, data);
                }
            case UniformType.CubeMap:
                if (image != undefined && typeof data === 'number' && Array.isArray(image)) {
                    const texture = this.gl.createTexture()!;
                    this.gl.activeTexture(this.gl.TEXTURE0 + data);
                    this.gl.bindTexture(this.gl.TEXTURE_CUBE_MAP, texture);

                    this.gl.texImage2D(this.gl.TEXTURE_CUBE_MAP_NEGATIVE_X, 0, this.gl.RGBA, image[0].width, image[0].height, 0, this.gl.RGBA, this.gl.UNSIGNED_BYTE, image[0]!);
                    this.gl.texImage2D(this.gl.TEXTURE_CUBE_MAP_NEGATIVE_Y, 0, this.gl.RGBA, image[1].width, image[1].height, 0, this.gl.RGBA, this.gl.UNSIGNED_BYTE, image[1]!);
                    this.gl.texImage2D(this.gl.TEXTURE_CUBE_MAP_NEGATIVE_Z, 0, this.gl.RGBA, image[2].width, image[2].height, 0, this.gl.RGBA, this.gl.UNSIGNED_BYTE, image[2]!);
                    this.gl.texImage2D(this.gl.TEXTURE_CUBE_MAP_POSITIVE_X, 0, this.gl.RGBA, image[3].width, image[3].height, 0, this.gl.RGBA, this.gl.UNSIGNED_BYTE, image[3]!);
                    this.gl.texImage2D(this.gl.TEXTURE_CUBE_MAP_POSITIVE_Y, 0, this.gl.RGBA, image[4].width, image[4].height, 0, this.gl.RGBA, this.gl.UNSIGNED_BYTE, image[4]!);
                    this.gl.texImage2D(this.gl.TEXTURE_CUBE_MAP_POSITIVE_Z, 0, this.gl.RGBA, image[5].width, image[5].height, 0, this.gl.RGBA, this.gl.UNSIGNED_BYTE, image[5]!);
                    
                    this.gl.generateMipmap(this.gl.TEXTURE_CUBE_MAP);

                    this.gl.texParameteri(this.gl.TEXTURE_CUBE_MAP, this.gl.TEXTURE_MIN_FILTER, this.gl.NEAREST);
                    this.gl.texParameteri(this.gl.TEXTURE_CUBE_MAP, this.gl.TEXTURE_MAG_FILTER, this.gl.NEAREST);
                    this.gl.uniform1i(this.programs[program_name].uniforms[name].location, data);
                }
        }
    }

    clearCanvas(clear_frame_buffers?: boolean) {
        for (let program_name of Object.keys(this.programs)) {
            this.gl.useProgram(this.programs[program_name].program);
            if (clear_frame_buffers) {
                for (let frame_buffer of Object.keys(this.programs[program_name].frame_buffers)) {
                    this.gl.bindFramebuffer(this.gl.FRAMEBUFFER, this.programs[program_name].frame_buffers[frame_buffer].frame_buffer);
                    this.gl.clearColor(...this.clear_color);
                    this.gl.clear(this.gl.COLOR_BUFFER_BIT | this.gl.DEPTH_BUFFER_BIT);
                }
            }
            this.gl.bindFramebuffer(this.gl.FRAMEBUFFER, null)
            this.gl.clearColor(...this.clear_color);
            this.gl.clear(this.gl.COLOR_BUFFER_BIT | this.gl.DEPTH_BUFFER_BIT);
        }
    }

    render() {
        this.clearCanvas(true);
        for (let call of this.draw_calls) {
            if (call.pre_draw) call.pre_draw(this);

            this.gl.useProgram(call.program.program);

            const program_name = call.program.name;

            if (call.options && call.options.depth_ignore) {
                this.gl.depthFunc(this.gl.LEQUAL);
            } else {
                this.gl.depthFunc(this.gl.LESS);
            }

            this.gl.bindBuffer(this.programs[program_name].attributes[this.program_vertex_data[program_name][0]].bufferType, this.programs[program_name].attributes[this.program_vertex_data[program_name][0]].buffer);
            this.gl.bufferData(this.programs[program_name].attributes[this.program_vertex_data[program_name][0]].bufferType, this.program_vertex_data[program_name][1], this.gl.STATIC_DRAW);

            this.gl.bindVertexArray(call.program.vao);
            for (let frame_buffer of call.frame_buffers) {
                this.gl.bindFramebuffer(this.gl.FRAMEBUFFER, this.programs[call.program.name].frame_buffers[frame_buffer].frame_buffer)
                this.gl.drawArrays((call.options && call.options.primitive_type !== undefined) ? call.options.primitive_type : this.gl.TRIANGLES, call.offset, call.drawLength);
            }
            this.gl.bindFramebuffer(this.gl.FRAMEBUFFER, null)
            if (!call.options || (call.options && call.options.draw_screen == undefined) || (call.options && call.options.draw_screen == true)) {
                this.gl.drawArrays((call.options && call.options.primitive_type !== undefined) ? call.options.primitive_type : this.gl.TRIANGLES, call.offset, call.drawLength);
            }
        }
    }
}

// Program is called 'shader-display'
export class ShaderDisplayCanvas extends Canvas {
    time: number;
    hovering: boolean;

    constructor(element: HTMLCanvasElement, width: number, height: number) {
        super(element, width, height);
        this.time = 0;
        this.hovering = false;
    }

    enter() {
        this.hovering = true;
    }

    leave() {
        this.hovering = false;
    }

    update() {
        if (!this.hovering) return;
        this.uniformData('iTime', 'shader-display', this.time);
        this.time += 1/60;
        this.render();
    }
}

// Program is called 'polyhedra'
export class PortfolioButtonCanvas extends Canvas {
    time: number;
    heldTime: number;
    hovering: boolean;

    constructor(element: HTMLCanvasElement, width: number, height: number) {
        super(element, width, height);
        this.time = 0;
        this.heldTime = 0;
        this.hovering = false;
    }

    enter() {
        this.hovering = true;
    }

    leave() {
        this.hovering = false;
    }

    update() {
        if (this.hovering && this.heldTime < 1) {
            this.heldTime += 0.08;
        } else if (!this.hovering && this.heldTime > 0) {
            this.heldTime -= 0.04;
        }
        this.uniformData('rot_factor', 'polyhedra', this.heldTime);
        this.uniformData('iTime', 'polyhedra', this.time);
        this.time += 1/60;
        this.render();
    }
}

// Program is called 'particle-sim'
export class ParticleSimCanvas extends Canvas {
    sim: ParticleSimulation;
    frames: number;
    constructor(element: HTMLCanvasElement, width: number, height: number) {
        super(element, width, height);
        this.clear_color = [0,0,0,0];
        const colors: number[][] = [];
        for (let i = 0; i < 500; i++) {
            let l = Math.random()*200;
            colors.push([l/2, l, 255]);
        }
        this.frames = 0;
        this.sim = new ParticleSimulation(colors);
    }

    update(dx: number, dy: number) {
        let [vertexPosition, vertexColor, circleColor] = this.sim.draw_scene();

        this.attributeData('vertexPosition', 'particle-sim', new Float32Array(vertexPosition));
        this.attributeData('vertexColor', 'particle-sim', new Float32Array(vertexColor));
        this.attributeData('circleColor', 'particle-sim', new Float32Array(circleColor));

        this.sim.update_physics(dx, dy);
        if (this.frames < 500) {
            this.sim.add_ball(300,450,7);
        }
        this.frames += 1;

        this.clearDrawCalls();
        this.addDrawCall('particle-sim', this.getDrawLength('particle-sim'), 0, 0);

        this.render();
    }
}

export class AtlasCanvas extends Canvas {
    mouse_pos: [number, number];
    ang_vel: [number, number];
    rotation: [number, number];
    view: mat4;
    proj: mat4;
    time: number;
    id_selected: number;

    constructor(element: HTMLCanvasElement, width: number, height: number, canvasManager: CanvasManager) {
        super(element, width, height);
        this.mouse_pos = [0,0];
        this.ang_vel = [0,0];
        this.rotation = [0,0];
        this.time = 0;
        this.proj = mat4.create()
        this.view = mat4.create();
        this.id_selected = 0;

        this.compileProgram('sky', canvasManager.programs['skybox'].vertex, canvasManager.programs['skybox'].fragment);

        this.addAttribute('screenPosition', 'sky', 2, this.gl.FLOAT, false, 0, 0, this.gl.ARRAY_BUFFER, true);
        this.attributeData('screenPosition', 'sky', new Float32Array([-1,1, 1,1, -1,-1, 1,1, 1,-1, -1,-1]))
        
        this.addUniform('skybox', 'sky', UniformType.CubeMap, 0);
        this.addUniform('time', 'sky', UniformType.Float, 1);
        this.addUniform('z_rot', 'sky', UniformType.Float, 1);
        this.addUniform('aspect_ratio', 'sky', UniformType.Float, 1);
        this.addUniform('proj', 'sky', UniformType.Matrix4, -1);
        this.addUniform('view', 'sky', UniformType.Matrix4, -1);

        this.uniformData('skybox', 'sky', 1, [...canvasManager.skyboxes['space']]);
        this.uniformData('time', 'sky', 0);
        this.uniformData('time', 'sky', this.rotation[0]);
        this.uniformData('aspect_ratio', 'sky', this.element.width/this.element.height);

        mat4.perspective(this.proj, Math.PI/2, width/height, 0.01, 100)
        mat4.lookAt(this.view, [0,0,0], [0,0,-1], [0,1,0]);
        this.uniformData('proj', 'sky',  this.proj);
        this.uniformData('view', 'sky', this.view);

        this.addDrawCall('sky', 6, 0, -1, [], {depth_ignore: true});

        this.compileProgram('3d-test', canvasManager.programs['3d-test'].vertex, canvasManager.programs['3d-test'].fragment);
        this.addUniform('time', '3d-test', UniformType.Float, 1);
        this.addUniform('selected', '3d-test', UniformType.Integer, 1);
        this.addUniform('proj', '3d-test', UniformType.Matrix4, -1);
        this.addUniform('view', '3d-test', UniformType.Matrix4, -1);
        this.uniformData('proj', '3d-test',  this.proj);
        this.uniformData('view', '3d-test', this.view);
        this.addAttribute('vertexPosition', '3d-test', 3, this.gl.FLOAT, false, 0, 0, this.gl.ARRAY_BUFFER, true);
        this.addAttribute('vertexColor', '3d-test', 3, this.gl.FLOAT, false, 0, 0, this.gl.ARRAY_BUFFER, false);

        this.compileProgram('3d-test-pick', canvasManager.programs['3d-test-pick'].vertex, canvasManager.programs['3d-test-pick'].fragment);
        this.addUniform('time',  '3d-test-pick', UniformType.Float, 1);
        this.addUniform('id',    '3d-test-pick', UniformType.Integer, 1);
        this.addUniform('proj',  '3d-test-pick', UniformType.Matrix4, -1);
        this.addUniform('view',  '3d-test-pick', UniformType.Matrix4, -1);
        this.uniformData('proj', '3d-test-pick',  this.proj);
        this.uniformData('view', '3d-test-pick', this.view);
        this.addAttribute('vertexPosition', '3d-test-pick', 3, this.gl.FLOAT, false, 0, 0, this.gl.ARRAY_BUFFER, true);
        this.addAttribute('vertexColor',    '3d-test-pick', 3, this.gl.FLOAT, false, 0, 0, this.gl.ARRAY_BUFFER, false);
        this.addFrameBuffer('pick-buffer', '3d-test-pick', this.element.width, this.element.height, [{attachment: this.gl.DEPTH_ATTACHMENT, internal_format: this.gl.DEPTH_COMPONENT16}], [this.gl.COLOR_ATTACHMENT0]);

        const ico = generateIcosphere();
        this.attributeData('vertexPosition', '3d-test', ico[0]);
        this.attributeData('vertexColor',    '3d-test', ico[1]);

        const len = this.getDrawLength('3d-test')/12;
        for (let i = 0; i < 12; i++) {
            this.addDrawCall('3d-test', len, len*i, 0, [], {}, (c: Canvas) => {
                c.uniformData('selected', '3d-test', (this.id_selected == (i+1)) ? 1 : 0);
            })
        }

        this.attributeData('vertexPosition', '3d-test-pick', ico[0]);
        this.attributeData('vertexColor',    '3d-test-pick', ico[1]);

        for (let i = 0; i < 12; i++) {
            this.addDrawCall('3d-test-pick', len, len*i, 0, ['pick-buffer'], {}, () => {
                this.uniformData('id', '3d-test-pick', i+1);
            })
        }

        this.compileProgram('title', canvasManager.programs['atlas-title'].vertex, canvasManager.programs['atlas-title'].fragment);
        this.addUniform('iChannel0', 'title', UniformType.Texture2D, 0)
        this.uniformData('iChannel0', 'title', 0, canvasManager.assets['atlas_title'])
        this.addAttribute('vertexPosition', 'title', 2, this.gl.FLOAT, false, 0, 0, this.gl.ARRAY_BUFFER, true);
        this.addAttribute('vertexColor', 'title', 2, this.gl.FLOAT, false, 0, 0, this.gl.ARRAY_BUFFER, false);
        this.attributeData('vertexPosition', 'title', new Float32Array([-0.3, 0.5,  0.3, 0.5,  0.3, 1,  -0.3, 0.5,  0.3, 1,  -0.3, 1]));
        this.attributeData('vertexColor', 'title', new Float32Array([0, 1,  1, 1,  1, 0,  0, 1,  1, 0,  0, 0]));

        this.addDrawCall('title', 6, 0, 1, [], {depth_ignore: true});
    }

    update(mouse_state: boolean, mouse_pos: [number, number]) {
        const mouse_delta = mouse_state ? [(this.mouse_pos[0]-mouse_pos[0])/400, (this.mouse_pos[1]-mouse_pos[1])/400] : [0,0]
        this.mouse_pos = [...mouse_pos];

        this.ang_vel[0] = mouse_delta[0] == 0 ? this.ang_vel[0] : mouse_delta[0];
        this.ang_vel[1] = mouse_delta[1] == 0 ? this.ang_vel[1] : mouse_delta[1];

        this.rotation[1] += this.ang_vel[1];
        const r = (this.rotation[1] % (Math.PI*2) + Math.PI*2) % (Math.PI*2);
        this.rotation[0] += this.ang_vel[0] * (r > Math.PI/2 && r < 3*Math.PI/2 ? 1 : -1);

        this.ang_vel[0] *= 0.8;
        this.ang_vel[1] *= 0.8;

        const f = [
            Math.cos(this.rotation[0])*Math.cos(this.rotation[1]),
            Math.sin(this.rotation[1]),
            Math.sin(this.rotation[0])*Math.cos(this.rotation[1]),
        ]

        mat4.lookAt(this.view, [0,0,0], f, [0,(r > Math.PI/2 && r < 3*Math.PI/2 ? 1 : -1),0]);

        this.uniformData('view', 'sky', this.view);
        this.uniformData('view', '3d-test', this.view);
        this.uniformData('view', '3d-test-pick', this.view);

        this.time += 1/60;
        this.uniformData('time', 'sky', this.time);
        this.uniformData('time', '3d-test', this.time);
        this.uniformData('time', '3d-test-pick', this.time);
        this.uniformData('z_rot', 'sky', this.rotation[0]);

        if (this.time % 1/6 < 1/6) {
            this.id_selected = this.getPixel('3d-test-pick', mouse_pos[0], this.element.height - mouse_pos[1], 'pick-buffer')[0]
        }

        this.render();
    }
}

// this is a little bit of a reminder to myself because every time i have to write this fucking boilerplate
// i forget how this works. gl.ARRAY_BUFFER is not just a value that tells webgl what kind of buffer it is,
// it binds the buffer to a global variable which you then use to give shit to the program


// vaos are a collection of how to access attributes. it will contain all the settings you have for giving data to
// attributes *only*. what happens when you bind it, is you are telling it to listen to all the pointers you set for them,
// so you bind it, make all the pointers, and then unbind it. right before you render the things which require the attributes
// you rebind it, and it skips having to set all of those every single frame.

export enum UniformType {
    Float,
    FloatArray,
    FloatVector,
    Integer,
    IntegerArray,
    IntegerVector,
    Matrix2,
    Matrix3,
    Matrix4,
    Texture2D,
    CubeMap
}

interface Program {
    name: string;
    program: WebGLProgram;
    vao: WebGLVertexArrayObject;
    attributes: {[name: string]: Attribute};
    uniforms: {[name: string]: Uniform};
    frame_buffers: {[name: string]: FrameBuffer};
}

interface DrawCall {
    program: Program;
    drawLength: number;
    offset: number;
    z_layer: number;
    frame_buffers: string[];
    options?: DrawCallOptions;
    pre_draw?: (c: Canvas) => void
}

interface DrawCallOptions {
    draw_screen?: boolean;
    depth_ignore?: boolean;
    primitive_type?: number;
}

interface Attribute {
    name: string;
    buffer: WebGLBuffer
    location: GLuint;
    size: number;
    type: GLenum;
    normalize: boolean;
    stride: number;
    offset: number;
    bufferType: GLenum;
    isVertexData: boolean;
}

interface Uniform {
    name: string;
    location: WebGLUniformLocation;
    type: UniformType;
    length: number;
}

interface TextureParams {
    mag_filter: number;
    min_filter: number;
    texture_wrap: [number, number];
}

interface ImageTexture {
    image: HTMLImageElement;
    slot: number;
    params: TextureParams;
}

interface CubemapTexture {
    images: HTMLImageElement[];
    slot: number;
    params: TextureParams;
}

interface FrameBuffer {
    frame_buffer: WebGLFramebuffer,
    size: [number, number];
    render_buffers: RenderBuffer[]; //attachment points of renderbuffers
    texture_types: number[]; //attachment points of textures
}

interface RenderBuffer {
    internal_format: number,
    attachment: number
}