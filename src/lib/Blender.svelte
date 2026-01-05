<script lang="ts">
    export let canvasManager;
    let viewportWidth: number, viewportHeight: number;
</script>

<div id="main">
    <div id="viewport-wrapper" bind:clientWidth={viewportWidth} bind:clientHeight={viewportHeight}>
        <div id="header">
            <h1><u>3D Art</u></h1>
            <img id="horizontal-bar" src="./water_bar.gif" alt="bar" />
        </div>
        <p>
            Here are some of my 3D projects
        </p>
    </div>
</div>

<style>
    #main {
        background:linear-gradient(rgba(0, 0, 0, 0.3), rgba(0, 0, 0, 0.3)), url('./src/assets/blender art/fractal planet.png');
        background-size: 100vw;
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