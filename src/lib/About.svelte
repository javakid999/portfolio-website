<script lang="ts">
    import { onMount } from "svelte";
    import Dragwindow from "./Dragwindow.svelte";
    import { ParticleSimCanvas } from "./canvas";
    import type { CanvasManager } from "./canvasManager";

    export let canvasManager: CanvasManager;
    
    let viewportWidth: number, viewportHeight: number;
    let pikaVirus: HTMLSpanElement;
    let canvasElement: HTMLCanvasElement;
    let c: ParticleSimCanvas;
    let rect = [0,0,0,0]
    onMount(() => {
        const starPositions: number[] = [5, 0, 10, -1, 13, 0, 16, 2, 17, 6, 22, 5, 23, 1];
        const starElements = document.getElementsByClassName('star-deco');
        const stars: HTMLImageElement[] = [].slice.call(starElements);
        stars.forEach((star, i) => {
            star.style.transform = `translate(${starPositions[i*2]}em, ${starPositions[i*2+1]}em)`
        });

        c = new ParticleSimCanvas(canvasElement, 250, 250);

        c.compileProgram(canvasManager.programs['circle'].vertex, canvasManager.programs['circle'].fragment);
        c.addAttribute('vertexPosition', 2, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, true);
        c.attributeData('vertexPosition', new Float32Array([-1,-1, 1,1, -1,1, -1,-1, 1,-1, 1,1]));
        c.addAttribute('vertexColor', 2, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, false);
        c.attributeData('vertexColor', new Float32Array([0,0, 1,1, 0,1, 0,0, 1,0, 1,1]));
        c.addAttribute('circleColor', 3, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, false);

        renderTick();
    })

    function renderTick() {
        rect[2] = rect[0]
        rect[3] = rect[1]
        let newRect = canvasElement.getBoundingClientRect();
        rect[0] = newRect.left;
        rect[1] = newRect.top;
        c.update(rect[0] - rect[2], rect[1] - rect[3]);
        requestAnimationFrame(renderTick);
    }

    function createPikachu() {
        if (pikaVirus.children.length >= 16) return;
        const img = new Image();
        img.src = './assets-about/pikachu.gif'
        img.width = 30;
        img.height = 30;
        img.onclick = () => {img.src = './assets-about/raichu.gif'};
        pikaVirus.appendChild(img);
    }
</script>

<div id="main">
    <div id="viewport-wrapper" bind:clientWidth={viewportWidth} bind:clientHeight={viewportHeight}>
        <div id="header">
            <h1><u>About Me</u></h1>
            <img id="horizontal-bar" src="./water_bar.gif" alt="bar" />
        </div>
        <p>
            Hello! Welcome to my about page. <br/><br/>
            When I was 10 years old, I read the book "Javascript for Kids" by Nick Morgan, and have been obsessed with programming ever since. <br/>
            I created this website as a place to host my many projects I've worked on whilst learning Computer Science.<br/>
            Over the years I've also been interested in 3D modeling and music production, and you'll find those projects on this website too.<br/>
            I'm currently 18, and a freshman studying Copmuter Science at UMass Amherst.<br/>
            If you'd like to reach out, business-related or otherwise, feel free to reach out to my email, <span class="yellow">charlescall@umass.edu</span>.<br/><br/>
            Site last updated: November 4th, 2024
        </p>
        <Dragwindow ParentWidth={viewportWidth} ParentHeight={viewportHeight} Title={"water.exe"} id={3}>
            <div id="canvas-wrapper" role="button" tabindex=0>
                <canvas bind:this={canvasElement} />
            </div>
        </Dragwindow>
        <span id="stamps">
            <img src="./src/assets/large blinkies/vaporwave.png" alt="vaporwave" style="width:88px;height:31px;"/>
            <img src="./src/assets/large blinkies/88x31nocookie.gif" alt="cookies"/>
            <img src="./src/assets/large blinkies/88x31neocities.gif" alt="neocities"/>
            <img src="./src/assets/large blinkies/88x31computer.gif" alt="computer"/>
        </span>
        <div id="pika">
            <!-- svelte-ignore a11y-click-events-have-key-events -->
            <!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
            <img src="./src/assets/pikachu.gif" alt="pika" style="width: 400px;" on:click={createPikachu}/>
        </div>
        <span id="pikachu-virus" bind:this={pikaVirus}></span>
    </div>
</div>

<style>
    #main {
        background:linear-gradient(rgba(0, 0, 0, 0.3), rgba(0, 0, 0, 0.3)), url('./backgrounds/bubbles2.jpg');
        background-size: 30vw;
        width: 100%;
        height: 100%;
        text-align: center;
        overflow-y: auto;
    }
    #horizontal-bar {
        height: 0.5em;
        width: 50vw;
        object-fit: cover;
    }
    #viewport-wrapper {
        height: 100%;
        overflow:hidden;
        display: flex;
        flex-direction: column;
        position: relative;
    }
    #stamps {
        position: relative;
    }
    #pika img {
        object-fit: none;
        object-position: left top;
        height: 103px;
    }
    #pika img:active {
        filter: brightness(75%);
    }
    #canvas-wrapper {
        background: radial-gradient(circle, rgba(2,0,36,1) 0%, rgba(0,0,0,1) 71%, rgba(0,212,255,0) 71%);
        background-position-y: -4px;
        background-repeat: no-repeat;
    }
    h1 {
        margin: 0;
        color: #ffffff;
    }
    p {
        color: #ffffff;
        font-size: 1.2em;
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