<script lang="ts">
    import { onDestroy, onMount } from "svelte";
    import { AtlasCanvas } from "./canvas";
    import type { CanvasManager } from "./canvasManager";

    export let canvasManager: CanvasManager;
    let viewportWidth: number, viewportHeight: number;
    let canvasElement: HTMLCanvasElement;

    let mouse_state = false;
    let mouse_pos: [number, number] = [0,0]
    let destroyed = false;

    onMount(() => {
        const c = new AtlasCanvas(canvasElement, viewportWidth, viewportHeight, canvasManager);

        let update = () => {
            if (destroyed) return;
            c.update(mouse_state, mouse_pos);
            requestAnimationFrame(update);
        }

        update();
    })

    onDestroy(() => {
        destroyed = true;
    })
</script>

<div id="viewport-wrapper" bind:clientWidth={viewportWidth} bind:clientHeight={viewportHeight}>
    <div id="header">
        <canvas bind:this={canvasElement} on:mousedown={() => {mouse_state = true}} on:mouseup={()=>{mouse_state = false}} on:mouseleave={()=>{mouse_state = false}} on:mousemove={(e) => {
            const r = canvasElement.getBoundingClientRect();
            mouse_pos[0] = (e.clientX - r.left) / r.width * viewportWidth;
            mouse_pos[1] = (e.clientY - r.top) / r.height * viewportHeight;
        }} id="atlas-canvas"></canvas>
    </div>
</div>

<style>
    #atlas-canvas {
        position: absolute;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
    }
    #viewport-wrapper {
        background-size: 30vw;
        align-items: center;
        height: 70svh;
        overflow:hidden;
        display: flex;
        flex-direction: column;
        position: relative;
    }
    @keyframes wave {
        0% {transform: translateY(-4px)}
        50% {transform: translateY(4px)}
        100% {transform: translateY(-4px)}
    }
    @keyframes spin {
        0% {transform: rotate(0deg)}
        100% {transform: rotate(360deg)}
    }
    @keyframes marquee-1 {
        0% {transform: translate(0%, 0)}
        50% {transform: translate(-100%, 0)}
        50.1% {transform: translate(100%, 0)}
        100% {transform: translate(0%, 0)}
    }
    @keyframes marquee-2 {
        0% {transform: translate(0%, 0)}
        100% {transform: translate(-200%, 0)}
    }
</style>