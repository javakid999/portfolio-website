interface Program {
    program: WebGLProgram;
    vao: WebGLVertexArrayObject;
    attributes: {[name: string]: Attribute};
    uniforms: {[name: string]: Uniform};
}

export enum UniformType {
    Float,
    FloatArray,
    Integer,
    IntegerArray,
    Matrix,
    Texture2D
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