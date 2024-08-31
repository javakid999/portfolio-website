<script lang="ts">
    import { onMount } from "svelte";
    import Dragwindow from "./Dragwindow.svelte";
    import { Canvas, UniformType } from "./canvas";
    import vsrcTest from '../shaders/snowflake/vertex.glsl?raw';
    import fsrcTest from '../shaders/snowflake/fragment.glsl?raw';
    let viewportWidth: number, viewportHeight: number;
    let canvasElement: HTMLCanvasElement;
    let c: Canvas;
    let isRunning = false;
    let time = 0;
    onMount(() => {
        const starPositions: number[] = [5, 0, 10, -1, 13, 0, 16, 2, 17, 6, 22, 5, 23, 1];
        const starElements = document.getElementsByClassName('star-deco');
        const stars: HTMLImageElement[] = [].slice.call(starElements);
        stars.forEach((star, i) => {
            star.style.transform = `translate(${starPositions[i*2]}em, ${starPositions[i*2+1]}em)`
        });

        c = new Canvas(canvasElement, 150, 150);
        c.compileProgram(vsrcTest, fsrcTest);
        c.addAttribute('vertexPosition', 2, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, true);
        c.attributeData('vertexPosition', new Float32Array([-1,-1, 1,1, -1,1, -1,-1, 1,-1, 1,1]));
        c.addAttribute('vertexColor', 3, c.gl.FLOAT, false, 0, 0, c.gl.ARRAY_BUFFER, false);
        c.attributeData('vertexColor', new Float32Array([0,0,0, 1,1,0, 0,1,0, 0,0,0, 1,0,0, 1,1,0]));
        c.addUniform('iTime', UniformType.Float, 1);
        c.uniformData('iTime', 0);
        c.addUniform('iChannel0', UniformType.Texture2D, 1);

        const bayer = new Image();
        bayer.src = "./src/assets/bayer8.png";
        bayer.onload = function() {
            c.uniformData('iChannel0', 0, bayer);
            c.render();
        }
    })

    function renderTick() {
        if (!isRunning) return;
        c.uniformData('iTime', time);
        time += 1/60;
        c.render();
        requestAnimationFrame(renderTick);
    }

    function startTick() {
        isRunning = true;
        requestAnimationFrame(renderTick);
    }

    function stopTick() {
        isRunning = false;
    }
</script>

<div id="main">
    <div id="viewport-wrapper" bind:clientWidth={viewportWidth} bind:clientHeight={viewportHeight}>
        <div id="header">
            <h1><u>OrangeLazer's Secret Bunker</u></h1>
            <img src="./rainbow_bar.gif" alt="bar" />
        </div>
        <p>
            Ahoy, fellow digital interloper! Welcome to my humble internet abode. Feel free to peruse these archives of my various creative endeavors.<br/>
            Check out my <span class="blue">About</span> page to learn more.<br/>
            Head to the <span class="blue">Atlas</span> for a complete list of this sites pages.<br/>
            Some windows will <span class="purple" id="wavy-line">
                <span class="wave" style="--i:1">m</span>
                <span class="wave" style="--i:2">o</span>
                <span class="wave" style="--i:3">v</span>
                <span class="wave" style="--i:4">e</span>
            </span>when you hover over them!<br/>
            But <span class="red">beware</span>! There may be more to this site than meets the eye!<br/>
            Thank you for reading traveller, and happy surfing ;-)<br/>
            <span class="yellow">This website is best experienced in fullscreen!</span>
        </p>

        <div id="eye-candy">
            <div id="solar-system">
                <div id="sun">
                    <img src="./blinkies/sun.gif" alt="sun" />
                </div>
                <div id="earth-orbit">
                    <div id="earth">
                        <img src="./blinkies/earth.gif" alt="earth"/>
                        <div id="moon-orbit">
                            <div id="moon">
                                <img src="./blinkies/moon.gif" alt="moon" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <img class="star-deco" alt="star" src="blinkies/anistarblinkr.gif"/>
            <img class="star-deco" alt="star" src="blinkies/anistarblinkr.gif"/>
            <img class="star-deco" alt="star" src="blinkies/anistarblinkr.gif"/>
            <img class="star-deco" alt="star" src="blinkies/anistarblinkr.gif"/>
            <img class="star-deco" alt="star" src="blinkies/anistarblinkr.gif"/>
            <img class="star-deco" alt="star" src="blinkies/anistarblinkr.gif"/>
            <img class="star-deco" alt="star" src="blinkies/anistarblinkr.gif"/>
        </div>

        <Dragwindow ParentWidth={viewportWidth} ParentHeight={viewportHeight} Title={"odd_guy.jpg"} id={1}>
            <img src="./src/assets/cat1.jpg" alt="kitty" />
        </Dragwindow>
        <Dragwindow ParentWidth={viewportWidth} ParentHeight={viewportHeight} Title={"horrific_beast.jpg"} id={2}>
            <img src="./src/assets/cat2.jpg" alt="kitty" />
        </Dragwindow>
        <Dragwindow ParentWidth={viewportWidth} ParentHeight={viewportHeight} Title={"snowflake"} id={3}>
            <div id="canvas-wrapper" role="button" tabindex=0 on:mouseenter={startTick} on:mouseleave={stopTick}>
                <canvas bind:this={canvasElement} />
            </div>
        </Dragwindow>

        <div id="blinkies">
            <span class="row">
                <span class="group-1">
                    <img alt="blinkie!" src="classic-blinkies/0005-citystars.gif" />
                    <img alt="blinkie!" src="classic-blinkies/59.gif" />
                    <img alt="blinkie!" src="classic-blinkies/ac.gif" />
                    <img alt="blinkie!" src="classic-blinkies/allgood.gif" />
                    <img alt="blinkie!" src="classic-blinkies/bad.gif" />
                    <img alt="blinkie!" src="classic-blinkies/home.gif" />
                    <img alt="blinkie!" src="classic-blinkies/barbieblinky.gif" />
                    <img alt="blinkie!" src="classic-blinkies/blinkieshiny.gif" />
                    <img alt="blinkie!" src="classic-blinkies/cinnamoroll.gif" />
                </span>
                <span class="group-2">
                    <img alt="blinkie!" src="classic-blinkies/eccojam.gif" />
                    <img alt="blinkie!" src="classic-blinkies/eyestrain.gif" />
                    <img alt="blinkie!" src="classic-blinkies/gec.gif" />
                    <img alt="blinkie!" src="classic-blinkies/hatetalentedpeopleblink.gif" />
                    <img alt="blinkie!" src="classic-blinkies/30.gif" />
                    <img alt="blinkie!" src="classic-blinkies/htmlblinkie.gif" />
                    <img alt="blinkie!" src="classic-blinkies/iloveglitter.gif" />
                    <img alt="blinkie!" src="classic-blinkies/night.gif" />
                    <img alt="blinkie!" src="classic-blinkies/firefox user.gif" />
                </span>
            </span>
            <span class="row">
                <span class="group-1">
                    <img alt="blinkie!" src="classic-blinkies/website4.gif" />
                    <img alt="blinkie!" src="classic-blinkies/ow.gif" />
                    <img alt="blinkie!" src="classic-blinkies/owned-by-a-cat.gif" />
                    <img alt="blinkie!" src="classic-blinkies/poke.gif" />
                    <img alt="blinkie!" src="classic-blinkies/q25.gif" />
                    <img alt="blinkie!" src="classic-blinkies/r3.gif" />
                    <img alt="blinkie!" src="classic-blinkies/savedragonsblinkie.gif" />
                    <img alt="blinkie!" src="classic-blinkies/scene.gif" />
                    <img alt="blinkie!" src="classic-blinkies/transrights.gif" />
                </span>
                <span class="group-2">
                    <img alt="blinkie!" src="classic-blinkies/witch.gif" />
                    <img alt="blinkie!" src="classic-blinkies/h9.gif" />
                    <img alt="blinkie!" src="classic-blinkies/h18.gif" />
                    <img alt="blinkie!" src="classic-blinkies/f36.gif" />
                    <img alt="blinkie!" src="classic-blinkies/e94.gif" />
                    <img alt="blinkie!" src="classic-blinkies/50.gif" />
                    <img alt="blinkie!" src="classic-blinkies/52.gif" />
                    <img alt="blinkie!" src="classic-blinkies/25.gif" />
                    <img alt="blinkie!" src="classic-blinkies/x14.gif" />
                </span>
            </span>
        </div>
    </div>
</div>

<style>
    #main {
        background-image: url('./backgrounds/galaxy0.gif');
        background-size: 15vw;
        width: 100%;
        height: 100%;
        text-align: center;
        overflow-y: auto;
    }
    #viewport-wrapper {
        height: 130%;
        overflow:hidden;
        display: flex;
        flex-direction: column;
        position: relative;
    }
    h1 {
        margin: 0;
        color: #ffffff;
    }
    p {
        color: #ffffff;
        font-size: 1.2em;
    }
    #wavy-line {
        position: relative;
    }
    .wave {
        display: inline-block;
        position: relative;
        animation: wave 1s infinite cubic-bezier(.36,0,.63,1);
        animation-delay: calc(.25s * var(--i));
    }
    @keyframes wave {
        0% {transform: translateY(-4px)}
        50% {transform: translateY(4px)}
        100% {transform: translateY(-4px)}
    }
    #blinkies {
        text-align: left;
        margin-top: auto;
        align-self: flex-end;
        overflow-y: hidden;
        overflow-x: hidden;
        width: 100%;
        height: 50px;
    }
    .row {
        display: grid;
        grid-template: 'a b c d e f g h i a2 b2 c2 d2 e2 f2 g2 h2 i2' auto;
        width: 200%;
    }
    .group-1 {
        position: relative;
        left: 0;
        width: 100%;
        overflow-x: visible;
        animation: marquee-1 16s linear infinite;
    }
    .group-2 {
        position: relative;
        left: 0;
        width: 100%;
        overflow-x: visible;
        animation: marquee-2 16s linear infinite;
    }
    .row img {
        justify-self: stretch;
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
    #solar-system {
        background-image: radial-gradient(circle, rgba(255,205,0,0.5719421557685574) 17%, rgba(207,52,52,0) 60%);
        position: relative;
        bottom: 30%;
        left: 15%;
        width: 10em;
        height: 10em;
    }
    #sun {
        position: relative;
        top: 3em;
        left: 3em;
        width: 4em;
        height: 4em;
        animation: spin 15s linear infinite;
    }
    #sun img {
        width: 100%;
        height: 100%;
    }
    #earth-orbit {
        position: absolute;
        width: 10em;
        height: 10em;
        top: 0;
        left: 0;
        animation: spin 7.5s linear infinite;
    }
    #earth {
        width: 3em;
        height: 3em;
        transform: translate(4.5em, 4.5em);
        animation: spin 2s linear infinite;
    }
    #earth img {
        width: 100%;
        height: 100%;
    }
    #moon-orbit {
        position: absolute;
        top: 0;
        left: 0;
        width: 3em;
        height: 3em;
        animation: spin 3.25s linear infinite
    }
    #moon {
        position: relative;
        top: 3em;
        width: 2em;
        height: 2em;
    }
    #moon img {
        width: 100%;
        height: 100%;
    }
    .star-deco {
        position: absolute;
    }
</style>