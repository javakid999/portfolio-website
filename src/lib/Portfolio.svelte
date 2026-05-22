<script lang="ts">
    import type { CanvasManager } from "./canvasManager";
    import PortfolioTabs from "./portfolio/PortfolioTabs.svelte";

    export let canvasManager: CanvasManager;

    let viewportWidth: number, viewportHeight: number;

</script>

<div id="viewport-wrapper" bind:clientWidth={viewportWidth} bind:clientHeight={viewportHeight}>
    <div id="header">
        <h1><u>Portfolio</u></h1>
    </div>
    <p>Here you will find all my past and present Computer Science projects!</p>
    <PortfolioTabs canvasManager={canvasManager} viewportHeight={viewportHeight} viewportWidth={viewportWidth}></PortfolioTabs>
    <div id="bubbles-left" class="bubble-column">
        <img src="assets-portfolio/bubble.png" alt="bubble" style="--i:1" width="60px"/>
        <img src="assets-portfolio/bubble.png" alt="bubble" style="--i:2" width="60px"/>
        <img src="assets-portfolio/bubble.png" alt="bubble" style="--i:3" width="60px"/>
        <img src="assets-portfolio/bubble.png" alt="bubble" style="--i:4" width="60px"/>
        <img src="assets-portfolio/bubble.png" alt="bubble" style="--i:5" width="60px"/>
        <img src="assets-portfolio/bubble.png" alt="bubble" style="--i:6" width="60px"/>
        <img src="assets-portfolio/bubble.png" alt="bubble" style="--i:7" width="60px"/>
    </div>
    <div id="bubbles-right" class="bubble-column">
        <img src="assets-portfolio/bubble.png" alt="bubble" style="--i:1" width="60px"/>
        <img src="assets-portfolio/bubble.png" alt="bubble" style="--i:2" width="60px"/>
        <img src="assets-portfolio/bubble.png" alt="bubble" style="--i:3" width="60px"/>
        <img src="assets-portfolio/bubble.png" alt="bubble" style="--i:4" width="60px"/>
        <img src="assets-portfolio/bubble.png" alt="bubble" style="--i:5" width="60px"/>
        <img src="assets-portfolio/bubble.png" alt="bubble" style="--i:6" width="60px"/>
        <img src="assets-portfolio/bubble.png" alt="bubble" style="--i:7" width="60px"/>
    </div>
    <img id="tree" src="assets-portfolio/tree.gif" alt="tree" />
    <img id="tree-2" src="assets-portfolio/tree.gif" alt="tree" />
</div>

<style>
    #viewport-wrapper {
        background-image: url('/backgrounds/dithered_water.png');
        image-rendering: pixelated;
        background-size: 200vh;
        text-align: center;
        height: 150svh;
        overflow:hidden;
        display: flex;
        flex-direction: column;
        align-items: center;
        position: relative;
    }
    #header {
        color: white;
        filter: drop-shadow(0 0 0.5rem black);
    }
    p {
        color: white;
        filter: drop-shadow(0 0 0.5rem black);
        font-size: 1.2em;
    }
    @keyframes float {
        0% {transform: translate(-20px, 1000px)}
        25% {transform: translate(20px, 750px)}
        50% {transform: translate(-20px, 500px)}
        75% {transform: translate(20px, 250px)}
        100% {transform: translate(-20px 0px)}
    }

    #tree {
        user-select: none;
        position: absolute;
        top: 50%;
        left: 0;
        width: 20em;
    }

    #tree-2 {
        user-select: none;
        position: absolute;
        top: 35%;
        right: 0;
        width: 20em;
    }

    #bubbles-left {
        width: 60px;
        position: absolute;
        left: 10em;
    }

    #bubbles-right {
        width: 60px;
        position: absolute;
        right: 10em;
    }

    .bubble-column img {
        animation: float 3s linear infinite;
        animation-delay: calc(-1 * .6s * var(--i));
    }
</style>