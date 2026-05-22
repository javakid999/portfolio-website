<script lang="ts">
    import { onDestroy, onMount } from "svelte";
    import { PortfolioButtonCanvas, UniformType } from "../canvas";
    import type { CanvasManager } from "../canvasManager";
    import StaticWindow from "../StaticWindow.svelte";
    import GameGallery from "./GameGallery.svelte";
    import MiscGallery from "./MiscGallery.svelte";
    import ShaderGallery from "./ShaderGallery.svelte";
    
    let tab_id = 1;
    export let viewportWidth;
    export let viewportHeight;
    export let canvasManager: CanvasManager;

    let destroyed = false;

    let canvasElement: HTMLCanvasElement;
    let canvasElement2: HTMLCanvasElement;
    let canvasElement3: HTMLCanvasElement;
    let c: PortfolioButtonCanvas;
    let c2: PortfolioButtonCanvas;
    let c3: PortfolioButtonCanvas;

    function initCanvases() {
        c = new PortfolioButtonCanvas(canvasElement, 30, 30);

        c.compileProgram('polyhedra', canvasManager.programs['polyhedra'].vertex, canvasManager.programs['polyhedra'].fragment);
        c.addAttribute('vertexPosition',  'polyhedra', 2, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, true);
        c.attributeData('vertexPosition', 'polyhedra', new Float32Array([-1,-1, 1,1, -1,1, -1,-1, 1,-1, 1,1]));
        c.addAttribute('vertexColor',     'polyhedra', 3, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, false);
        c.attributeData('vertexColor',    'polyhedra', new Float32Array([0,0,0, 1,1,0, 0,1,0, 0,0,0, 1,0,0, 1,1,0]));
        c.addUniform('iTime',     'polyhedra', UniformType.Float, 1, 0);
        c.addUniform('iChannel0', 'polyhedra', UniformType.Texture2D, 0, 0);
        c.createTexture(UniformType.Texture2D, 0, canvasManager.assets['bayer'])

        c.addUniform('shape_num',   'polyhedra', UniformType.Integer, 1, 0);
        c.addUniform('rot_factor',  'polyhedra', UniformType.Float, 1, 0);

        c2 = new PortfolioButtonCanvas(canvasElement2, 30, 30);

        c2.compileProgram('polyhedra', canvasManager.programs['polyhedra'].vertex, canvasManager.programs['polyhedra'].fragment);
        c2.addAttribute('vertexPosition',  'polyhedra', 2, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, true);
        c2.attributeData('vertexPosition', 'polyhedra', new Float32Array([-1,-1, 1,1, -1,1, -1,-1, 1,-1, 1,1]));
        c2.addAttribute('vertexColor',     'polyhedra', 3, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, false);
        c2.attributeData('vertexColor',    'polyhedra', new Float32Array([0,0,0, 1,1,0, 0,1,0, 0,0,0, 1,0,0, 1,1,0]));
        c2.addUniform('iTime',     'polyhedra', UniformType.Float, 1);
        c2.uniformData('iTime',    'polyhedra', 0);
        c2.addUniform('iChannel0', 'polyhedra', UniformType.Texture2D, 0, 0);
        c2.createTexture(UniformType.Texture2D, 0, canvasManager.assets['bayer'])

        c2.addUniform('shape_num',   'polyhedra', UniformType.Integer, 1, 1);
        c2.addUniform('rot_factor',  'polyhedra', UniformType.Float, 1, 0.5);

        c3 = new PortfolioButtonCanvas(canvasElement3, 30, 30);

        c3.compileProgram('polyhedra', canvasManager.programs['polyhedra'].vertex, canvasManager.programs['polyhedra'].fragment);
        c3.addAttribute('vertexPosition',  'polyhedra', 2, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, true);
        c3.attributeData('vertexPosition', 'polyhedra', new Float32Array([-1,-1, 1,1, -1,1, -1,-1, 1,-1, 1,1]));
        c3.addAttribute('vertexColor',     'polyhedra', 3, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, false);
        c3.attributeData('vertexColor',    'polyhedra', new Float32Array([0,0,0, 1,1,0, 0,1,0, 0,0,0, 1,0,0, 1,1,0]));
        c3.addUniform('iTime',     'polyhedra', UniformType.Float, 1);
        c3.uniformData('iTime',    'polyhedra', 0);
        c3.addUniform('iChannel0', 'polyhedra', UniformType.Texture2D, 0, 0);
        c3.createTexture(UniformType.Texture2D, 0, canvasManager.assets['bayer'])

        c3.addUniform('shape_num',   'polyhedra', UniformType.Integer, 1);
        c3.uniformData('shape_num',  'polyhedra', 2);
        c3.addUniform('rot_factor',  'polyhedra', UniformType.Float, 1);
        c3.uniformData('rot_factor', 'polyhedra', 1);
    }

    onMount(() => {
        initCanvases();

        c.addDrawCall('polyhedra', 6, 0, 0);
        c2.addDrawCall('polyhedra', 6, 0, 0);
        c3.addDrawCall('polyhedra', 6, 0, 0);

        requestAnimationFrame(renderTick);
    });

    onDestroy(() => {
        destroyed = true;
    })

    function renderTick() {
        if (destroyed) return;
        c.update()
        c2.update()
        c3.update()
        requestAnimationFrame(renderTick);
    }
</script>

<main>
    <div id="portfolio-buttons">
        <span>
            <button id="button-1" class:active={tab_id===0} on:click={() => tab_id = 0}>
                <div id="canvas-wrapper" role="button" tabindex=0 on:mouseenter={() => c.enter()} on:mouseleave={() => c.leave()}>
                    <canvas bind:this={canvasElement} />
                </div>
                <div class="button-text">GAMES</div>
            </button>
        </span>
        <button id="button-2" class:active={tab_id===1} on:click={() => tab_id = 1}>
            <div id="canvas-wrapper-2" role="button" tabindex=0 on:mouseenter={() => c2.enter()} on:mouseleave={() => c2.leave()}>
                <canvas bind:this={canvasElement2} />
            </div>
            <div class="button-text">SHADER GALLERY</div>
        </button>
        <button id="button-3" class:active={tab_id===2} on:click={() => tab_id = 2}>
            <div id="canvas-wrapper-3" role="button" tabindex=0 on:mouseenter={() => c3.enter()} on:mouseleave={() => c3.leave()}>
                <canvas bind:this={canvasElement3} />
            </div>
            <div class="button-text">MISC</div>
        </button>
    </div>
    <div id="tab-content">
        {#if tab_id == 0}
            <StaticWindow Title={"awesome_games.html"} id={1}>
                <GameGallery canvasManager={canvasManager}></GameGallery>
            </StaticWindow>
        {:else if tab_id == 1}
            <StaticWindow Title={"shader_gallery.html"} id={1}>
                <ShaderGallery canvasManager={canvasManager}></ShaderGallery>
            </StaticWindow>
        {:else if tab_id == 2}
            <StaticWindow Title={"misc_stuffs.html"} id={1}>
                <MiscGallery canvasManager={canvasManager}></MiscGallery>
            </StaticWindow>
        {/if}
    </div>
</main>

<style>
    #tab-content {
        margin-top: 5em;
    }
    #portfolio-buttons {
        width: 45em;
        margin-left: auto;
        margin-right: auto;
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
</style>