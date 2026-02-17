<script lang="ts">
    import { onDestroy, onMount } from "svelte";
    import { PortfolioButtonCanvas, UniformType } from "./canvas";
    import type { CanvasManager } from "./canvasManager";
    import Dragwindow from "./Dragwindow.svelte";
    import GameGallery from "./GameGallery.svelte";
    import ShaderGallery from "./ShaderGallery.svelte";
    
    let activeTab: typeof ShaderGallery | typeof GameGallery = ShaderGallery;
    let tab_id = 1;
    export let viewportWidth;
    export let viewportHeight;
    export let canvasManager: CanvasManager;

    let destroyed = false;

    function changeTab(element: HTMLDivElement, id: number) {
        switch(id) {
            case 0:
                activeTab = GameGallery;
                tab_id = 0;
                break;
            case 1:
                activeTab = ShaderGallery;
                tab_id = 1;
                break;
            case 2:
                break;
        }
    }

    let canvasElement: HTMLCanvasElement;
    let canvasElement2: HTMLCanvasElement;
    let canvasElement3: HTMLCanvasElement;
    let buttonElement: HTMLDivElement;
    let buttonElement2: HTMLDivElement;
    let buttonElement3: HTMLDivElement;
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
        c.addUniform('iTime',     'polyhedra', UniformType.Float, 1);
        c.uniformData('iTime',    'polyhedra', 0);
        c.addUniform('iChannel0', 'polyhedra', UniformType.Texture2D, 1);

        c.addUniform('shape_num',   'polyhedra', UniformType.Integer, 1);
        c.uniformData('shape_num',  'polyhedra', 0);
        c.addUniform('rot_factor',  'polyhedra', UniformType.Float, 1);
        c.uniformData('rot_factor', 'polyhedra', 0);

        c2 = new PortfolioButtonCanvas(canvasElement2, 30, 30);

        c2.compileProgram('polyhedra', canvasManager.programs['polyhedra'].vertex, canvasManager.programs['polyhedra'].fragment);
        c2.addAttribute('vertexPosition',  'polyhedra', 2, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, true);
        c2.attributeData('vertexPosition', 'polyhedra', new Float32Array([-1,-1, 1,1, -1,1, -1,-1, 1,-1, 1,1]));
        c2.addAttribute('vertexColor',     'polyhedra', 3, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, false);
        c2.attributeData('vertexColor',    'polyhedra', new Float32Array([0,0,0, 1,1,0, 0,1,0, 0,0,0, 1,0,0, 1,1,0]));
        c2.addUniform('iTime',     'polyhedra', UniformType.Float, 1);
        c2.uniformData('iTime',    'polyhedra', 0);
        c2.addUniform('iChannel0', 'polyhedra', UniformType.Texture2D, 1);

        c2.addUniform('shape_num',   'polyhedra', UniformType.Integer, 1);
        c2.uniformData('shape_num',  'polyhedra', 1);
        c2.addUniform('rot_factor',  'polyhedra', UniformType.Float, 1);
        c2.uniformData('rot_factor', 'polyhedra', 0.5);

        c3 = new PortfolioButtonCanvas(canvasElement3, 30, 30);

        c3.compileProgram('polyhedra', canvasManager.programs['polyhedra'].vertex, canvasManager.programs['polyhedra'].fragment);
        c3.addAttribute('vertexPosition',  'polyhedra', 2, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, true);
        c3.attributeData('vertexPosition', 'polyhedra', new Float32Array([-1,-1, 1,1, -1,1, -1,-1, 1,-1, 1,1]));
        c3.addAttribute('vertexColor',     'polyhedra', 3, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, false);
        c3.attributeData('vertexColor',    'polyhedra', new Float32Array([0,0,0, 1,1,0, 0,1,0, 0,0,0, 1,0,0, 1,1,0]));
        c3.addUniform('iTime',     'polyhedra', UniformType.Float, 1);
        c3.uniformData('iTime',    'polyhedra', 0);
        c3.addUniform('iChannel0', 'polyhedra', UniformType.Texture2D, 1);

        c3.addUniform('shape_num',   'polyhedra', UniformType.Integer, 1);
        c3.uniformData('shape_num',  'polyhedra', 2);
        c3.addUniform('rot_factor',  'polyhedra', UniformType.Float, 1);
        c3.uniformData('rot_factor', 'polyhedra', 1);
    }

    onMount(() => {
        initCanvases();

        c.uniformData('iChannel0',  'polyhedra', 0, canvasManager.assets['bayer']);
        c2.uniformData('iChannel0', 'polyhedra', 0, canvasManager.assets['bayer']);
        c3.uniformData('iChannel0', 'polyhedra', 0, canvasManager.assets['bayer']);

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
            <button id="button-1" class:active={tab_id===0}>
                <!-- svelte-ignore a11y-click-events-have-key-events -->
                <div id="canvas-wrapper" bind:this={buttonElement} on:click={() =>changeTab(buttonElement, 0)} role="button" tabindex=0 on:mouseenter={() => c.enter()} on:mouseleave={() => c.leave()}>
                    <canvas bind:this={canvasElement} />
                </div>
                <div class="button-text">GAMES</div>
            </button>
        </span>
        <button id="button-2" class:active={tab_id===1}>
            <!-- svelte-ignore a11y-click-events-have-key-events -->
            <div id="canvas-wrapper-2" bind:this={buttonElement2} on:click={() => changeTab(buttonElement2, 1)} role="button" tabindex=0 on:mouseenter={() => c2.enter()} on:mouseleave={() => c2.leave()}>
                <canvas bind:this={canvasElement2} />
            </div>
            <div class="button-text">SHADER GALLERY</div>
        </button>
        <button id="button-3" class:active={tab_id===2}>
            <!-- svelte-ignore a11y-click-events-have-key-events -->
            <div id="canvas-wrapper-3" bind:this={buttonElement3} on:click={() => changeTab(buttonElement3, 2)} role="button" tabindex=0 on:mouseenter={() => c3.enter()} on:mouseleave={() => c3.leave()}>
                <canvas bind:this={canvasElement3} />
            </div>
            <div class="button-text">MISC</div>
        </button>
    </div>
        <Dragwindow ParentWidth={viewportWidth} ParentHeight={viewportHeight} Title={"shader_gallery.html"} id={1}>
            <svelte:component this={activeTab} canvasManager={canvasManager}/>
        </Dragwindow>
</main>

<style>
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
</style>