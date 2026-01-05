<script lang="ts">
    import { onMount } from "svelte";
    import { ShaderDisplayCanvas, UniformType } from "./canvas";

    export let canvasManager;

    let canvasElement: HTMLCanvasElement;
    let canvasElement2: HTMLCanvasElement;
    let canvasElement3: HTMLCanvasElement;
    let canvasElement4: HTMLCanvasElement;
    let canvasElement5: HTMLCanvasElement;

    let c: ShaderDisplayCanvas;
    let c2: ShaderDisplayCanvas;
    let c3: ShaderDisplayCanvas;
    let c4: ShaderDisplayCanvas;
    let c5: ShaderDisplayCanvas;

    onMount(() => {
        c = new ShaderDisplayCanvas(canvasElement, 200, 200);

        c.compileProgram(canvasManager.programs['snowflake'].vertex, canvasManager.programs['snowflake'].fragment);
        c.addAttribute('vertexPosition', 2, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, true);
        c.attributeData('vertexPosition', new Float32Array([-1,-1, 1,1, -1,1, -1,-1, 1,-1, 1,1]));
        c.addAttribute('vertexColor', 3, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, false);
        c.attributeData('vertexColor', new Float32Array([0,0,0, 1,1,0, 0,1,0, 0,0,0, 1,0,0, 1,1,0]));
        c.addUniform('iTime', UniformType.Float, 1);
        c.uniformData('iTime', 0);
        c.addUniform('iChannel0', UniformType.Texture2D, 1);
        c.uniformData('iChannel0', 0, canvasManager.assets['bayer']);

        c.render();

        c2 = new ShaderDisplayCanvas(canvasElement2, 300, 300);

        c2.compileProgram(canvasManager.programs['donut'].vertex, canvasManager.programs['donut'].fragment);
        c2.addAttribute('vertexPosition', 2, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, true);
        c2.attributeData('vertexPosition', new Float32Array([-1,-1, 1,1, -1,1, -1,-1, 1,-1, 1,1]));
        c2.addAttribute('vertexColor', 3, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, false);
        c2.attributeData('vertexColor', new Float32Array([0,0,0, 1,1,0, 0,1,0, 0,0,0, 1,0,0, 1,1,0]));
        c2.addUniform('iTime', UniformType.Float, 1);
        c2.uniformData('iTime', 0);
        c2.addUniform('iChannel0', UniformType.Texture2D, 1);
        c2.addUniform('iChannel1', UniformType.Texture2D, 1);

        c2.uniformData('iChannel0', 0, canvasManager.assets['bayer']);
        c2.uniformData('iChannel1', 1, canvasManager.assets['times_ascii']);

        c2.render();

        c3 = new ShaderDisplayCanvas(canvasElement3, 300, 300);

        c3.compileProgram(canvasManager.programs['metaballs'].vertex, canvasManager.programs['metaballs'].fragment);
        c3.addAttribute('vertexPosition', 2, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, true);
        c3.attributeData('vertexPosition', new Float32Array([-1,-1, 1,1, -1,1, -1,-1, 1,-1, 1,1]));
        c3.addAttribute('vertexColor', 3, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, false);
        c3.attributeData('vertexColor', new Float32Array([0,0,0, 1,1,0, 0,1,0, 0,0,0, 1,0,0, 1,1,0]));
        c3.addUniform('iTime', UniformType.Float, 1);
        c3.uniformData('iTime', 0);

        c3.render();

        c4 = new ShaderDisplayCanvas(canvasElement4, 200, 200);

        c4.compileProgram(canvasManager.programs['mandelbrot'].vertex, canvasManager.programs['mandelbrot'].fragment);
        c4.addAttribute('vertexPosition', 2, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, true);
        c4.attributeData('vertexPosition', new Float32Array([-1,-1, 1,1, -1,1, -1,-1, 1,-1, 1,1]));
        c4.addAttribute('vertexColor', 3, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, false);
        c4.attributeData('vertexColor', new Float32Array([0,0,0, 1,1,0, 0,1,0, 0,0,0, 1,0,0, 1,1,0]));
        c4.addUniform('iTime', UniformType.Float, 1);
        c4.uniformData('iTime', 0);

        c4.render();

        c5 = new ShaderDisplayCanvas(canvasElement5, 300, 300);

        c5.compileProgram(canvasManager.programs['julia'].vertex, canvasManager.programs['julia'].fragment);
        c5.addAttribute('vertexPosition', 2, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, true);
        c5.attributeData('vertexPosition', new Float32Array([-1,-1, 1,1, -1,1, -1,-1, 1,-1, 1,1]));
        c5.addAttribute('vertexColor', 3, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, false);
        c5.attributeData('vertexColor', new Float32Array([0,0,0, 1,1,0, 0,1,0, 0,0,0, 1,0,0, 1,1,0]));
        c5.addUniform('iTime', UniformType.Float, 1);
        c5.uniformData('iTime', 0);

        c5.render();

        renderTick();
    });

    function renderTick() {
        c.update();
        c2.update();
        c3.update();
        c4.update();
        c5.update();
        requestAnimationFrame(renderTick);
    }
</script>

<div id="main">
    <div id="header">
        <h1><u>Shader Gallery</u></h1>
    </div>
    <p>Hover over each shader to play it</p>
    <canvas bind:this={canvasElement2} role="button" tabindex=0 on:mouseenter={() => c2.enter()} on:mouseleave={() => c2.leave()}></canvas>
    <canvas bind:this={canvasElement} role="button" tabindex=0 on:mouseenter={() => c.enter()} on:mouseleave={() => c.leave()}></canvas>
    <canvas bind:this={canvasElement3} role="button" tabindex=0 on:mouseenter={() => c3.enter()} on:mouseleave={() => c3.leave()}></canvas>
    <canvas bind:this={canvasElement4} role="button" tabindex=0 on:mouseenter={() => c4.enter()} on:mouseleave={() => c4.leave()}></canvas>
    <canvas bind:this={canvasElement5} role="button" tabindex=0 on:mouseenter={() => c5.enter()} on:mouseleave={() => c5.leave()}></canvas>
</div>

<style>
    #main {
        width: 1000px;
        height: 500px;
        overflow-y: scroll;
        background-image: url('./backgrounds/water.jpg');
        background-size: 15vw;
        color: white;
    }
    canvas {
        margin: 0.5em;
        border: 2px solid grey;
    }
</style>