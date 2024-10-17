import type { ProgramSrc } from "../util/load";

export class CanvasManager {
    contexts: {[id: string]: WebGL2RenderingContext}
    programs: {[id: string]: ProgramSrc}
    assets: {[id: string]: HTMLImageElement}

    constructor(programs: {[id: string]: ProgramSrc}, assets: {[id: string]: HTMLImageElement}) {
        this.contexts = {};
        this.programs = programs;
        this.assets = assets;
    }
}