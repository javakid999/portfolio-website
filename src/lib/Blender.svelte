<script lang="ts">
    export let canvasManager;
    let viewportWidth: number, viewportHeight: number;
</script>

<div id="viewport-wrapper" bind:clientWidth={viewportWidth} bind:clientHeight={viewportHeight}>
    <div id="content">
        <div id="filter"></div>
        <div id="header">
            <h1><u>3D Art</u></h1>
            <img id="horizontal-bar" src="./water_bar.gif" alt="bar" />
        </div>
        <p>
            Here are some of my 3D projects. I used Blender and Bryce 3D and digitally edited them afterwards.
        </p>
        <div id="image-gallery">
            <img src="blender/mountain_glitch_final.png" alt="mountain"/>
            <img src="blender/canyon.png" alt="canyon"/>
            <img src="blender/cherry_final_2.png" alt="cherry blossom"/>
            <img src="blender/planet.png" alt="space"/>
            <img src="blender/planet2.png" alt="space 2"/>
            <img src="blender/fractal planet.png" alt="fractal planet"/>
        </div>
    </div>
</div>

<style>
    #viewport-wrapper {
        height: 150svh;
        display: flex;
    }
    #viewport-wrapper::before {
        content: "";
        position: absolute;
        width: 100%;
        height: 100%;
        background:linear-gradient(rgba(0, 0, 0, 0.3), rgba(0, 0, 0, 0.3)), url('/blender/fractal planet.png');
        background-size: 100vw;
        filter: brightness(0.5) blur(3px);
    }
    #content {
        position: relative;
        display: flex;
        flex-direction: column;
        align-items: center;
    }
    #horizontal-bar {
        height: 0.5em;
        width: 50vw;
        object-fit: cover;
    }
    #image-gallery {
        width: 90%;
    }
    #image-gallery img {
        width: 45%;
        border: solid 3px#606060;
        border-top: solid 3px #ffffffbb;
        border-left: solid 3px #ffffffbb;
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