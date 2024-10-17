<script lang="ts">
    import { onMount } from "svelte";
    import { PortfolioButtonCanvas, UniformType } from "./canvas";
    import type { CanvasManager } from "./canvasManager";
    import Dragwindow from "./Dragwindow.svelte";
    import ShaderGallery from './ShaderGallery.svelte';

    export let canvasManager: CanvasManager;

    let viewportWidth: number, viewportHeight: number;
    
    let canvasElement: HTMLCanvasElement;
    let canvasElement2: HTMLCanvasElement;
    let canvasElement3: HTMLCanvasElement;
    let c: PortfolioButtonCanvas;
    let c2: PortfolioButtonCanvas;
    let c3: PortfolioButtonCanvas;


    let activeTab = ShaderGallery;

    function changeTab(element: HTMLButtonElement, id: number) {
        element.className = 'active';
    }

    function initCanvases() {
        c = new PortfolioButtonCanvas(canvasElement, 30, 30);

        c.compileProgram(canvasManager.programs['polyhedra'].vertex, canvasManager.programs['polyhedra'].fragment);
        c.addAttribute('vertexPosition', 2, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, true);
        c.attributeData('vertexPosition', new Float32Array([-1,-1, 1,1, -1,1, -1,-1, 1,-1, 1,1]));
        c.addAttribute('vertexColor', 3, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, false);
        c.attributeData('vertexColor', new Float32Array([0,0,0, 1,1,0, 0,1,0, 0,0,0, 1,0,0, 1,1,0]));
        c.addUniform('iTime', UniformType.Float, 1);
        c.uniformData('iTime', 0);
        c.addUniform('iChannel0', UniformType.Texture2D, 1);

        c.addUniform('shape_num', UniformType.Integer, 1);
        c.uniformData('shape_num', 0);
        c.addUniform('rot_factor', UniformType.Float, 1);
        c.uniformData('rot_factor', 0);

        c2 = new PortfolioButtonCanvas(canvasElement2, 30, 30);

        c2.compileProgram(canvasManager.programs['polyhedra'].vertex, canvasManager.programs['polyhedra'].fragment);
        c2.addAttribute('vertexPosition', 2, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, true);
        c2.attributeData('vertexPosition', new Float32Array([-1,-1, 1,1, -1,1, -1,-1, 1,-1, 1,1]));
        c2.addAttribute('vertexColor', 3, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, false);
        c2.attributeData('vertexColor', new Float32Array([0,0,0, 1,1,0, 0,1,0, 0,0,0, 1,0,0, 1,1,0]));
        c2.addUniform('iTime', UniformType.Float, 1);
        c2.uniformData('iTime', 0);
        c2.addUniform('iChannel0', UniformType.Texture2D, 1);

        c2.addUniform('shape_num', UniformType.Integer, 1);
        c2.uniformData('shape_num', 1);
        c2.addUniform('rot_factor', UniformType.Float, 1);
        c2.uniformData('rot_factor', 0.5);

        c3 = new PortfolioButtonCanvas(canvasElement3, 30, 30);

        c3.compileProgram(canvasManager.programs['polyhedra'].vertex, canvasManager.programs['polyhedra'].fragment);
        c3.addAttribute('vertexPosition', 2, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, true);
        c3.attributeData('vertexPosition', new Float32Array([-1,-1, 1,1, -1,1, -1,-1, 1,-1, 1,1]));
        c3.addAttribute('vertexColor', 3, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, false);
        c3.attributeData('vertexColor', new Float32Array([0,0,0, 1,1,0, 0,1,0, 0,0,0, 1,0,0, 1,1,0]));
        c3.addUniform('iTime', UniformType.Float, 1);
        c3.uniformData('iTime', 0);
        c3.addUniform('iChannel0', UniformType.Texture2D, 1);

        c3.addUniform('shape_num', UniformType.Integer, 1);
        c3.uniformData('shape_num', 2);
        c3.addUniform('rot_factor', UniformType.Float, 1);
        c3.uniformData('rot_factor', 1);
    }

    onMount(() => {
        initCanvases();

        c.uniformData('iChannel0', 0, canvasManager.assets['bayer']);
        c2.uniformData('iChannel0', 0, canvasManager.assets['bayer']);
        c3.uniformData('iChannel0', 0, canvasManager.assets['bayer']);

        requestAnimationFrame(renderTick);
    });

    function renderTick() {
        c.update()
        c2.update()
        c3.update()
        requestAnimationFrame(renderTick);
    }
</script>

<div id="main">
    <div id="viewport-wrapper" bind:clientWidth={viewportWidth} bind:clientHeight={viewportHeight}>
        <div id="header">
            <h1><u>Portfolio</u></h1>
        </div>
        <p>Here you will find all my past and present Computer Science adjacent projects!</p>
        <span id="portfolio-buttons">
            <span>
                <button id="button-1">
                    <div id="canvas-wrapper" role="button" tabindex=0 on:mouseenter={() => c.enter()} on:mouseleave={() => c.leave()}>
                        <canvas bind:this={canvasElement} />
                    </div>
                    <div class="button-text">GAMES</div>
                </button>
            </span>
            <button id="button-2" class="active">
                <div id="canvas-wrapper-2" role="button" tabindex=0 on:mouseenter={() => c2.enter()} on:mouseleave={() => c2.leave()}>
                    <canvas bind:this={canvasElement2} />
                </div>
                <div class="button-text">SHADER GALLERY</div>
            </button>
            <button id="button-3">
                <div id="canvas-wrapper-3" role="button" tabindex=0 on:mouseenter={() => c3.enter()} on:mouseleave={() => c3.leave()}>
                    <canvas bind:this={canvasElement3} />
                </div>
                <div class="button-text">MISC</div>
            </button>
        </span>
        <Dragwindow ParentWidth={viewportWidth} ParentHeight={viewportHeight} Title={"Shader Gallery"} id={1}>
            <svelte:component this={activeTab} canvasManager={canvasManager}/>
        </Dragwindow>
    </div>
</div>

<style>
    #main {
        background-image: url('./backgrounds/frutiger-aero.jpeg');
        background-size: 100vw;
        background-position-y: center;
        width: 100%;
        height: 100%;
        text-align: center;
        overflow-y: auto;
    }
    #viewport-wrapper {
        height: 100%;
        overflow:hidden;
        display: flex;
        flex-direction: column;
        position: relative;
    }
    #header {
        color: white;
        filter: drop-shadow(0 0 0.5rem black);
    }
    #portfolio-buttons {
        width: 45em;
    }
    #portfolio-buttons button {
        margin: 0;
        width: 150px + 0.5em;
        height: 150px + 0.5em;
        padding: 0.5em;
        border: 0px;
        color: #ffffff;
        background-color: rgba(0,0,0,0.2);
        position: relative;
    }
    .button-text {
        position: absolute;
        font-size: 1.2em;
        top: 40%;
        left: 0;
        right: 0;
        margin-inline: auto;
    }
    #portfolio-buttons canvas {
        width: 150px;
        height: 150px;
        image-rendering: pixelated;
    }
    #portfolio-buttons button:active {
        background-color: rgba(0,0,0,0.5);
    }
    #portfolio-buttons button.active {
        background-color: rgba(0,0,0,0.5);
    }
    p {
        color: white;
        filter: drop-shadow(0 0 0.5rem black);
        font-size: 1.2em;
    }
</style>