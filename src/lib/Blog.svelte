<script lang="ts">
    export let canvasManager;
    let viewportWidth: number, viewportHeight: number;
</script>

<div id="viewport-wrapper" bind:clientWidth={viewportWidth} bind:clientHeight={viewportHeight}>
    <div id="content">
        <h1><u>Blog</u></h1>
        <p>Welcome to the blog section of my website! Here is where you'll find some of my miscellaneous thoughts or projects that aren't fully deserving of their own page. I hope you enjoy! :) </p>
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
        height: 150%;
        image-rendering: pixelated;
        background:linear-gradient(rgba(0, 0, 0, 0.3), rgba(0, 0, 0, 0.3)), url('backgrounds/library.png');
        background-size: 100vw;
    }
    #content {
        position: relative;
        display: flex;
        flex-direction: column;
        align-items: center;
        text-align: center;
        width: 100%;
    }
    #horizontal-bar {
        height: 0.5em;
        width: 50vw;
        object-fit: cover;
    }
    h1 {
        margin: 0;
        text-align: center;
        color: #ffffff;
        text-shadow:#000000 2px 2px 3px;
    }
    p {
        font-size: 24px;
        color: white;
        text-shadow:#000000 2px 2px 3px;
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