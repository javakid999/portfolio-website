<script lang="ts">
    export let canvasManager;
</script>

<div id="main">
    <div id="header">
        <h1><u>Games</u></h1>
    </div>
    <p>Click on each game to play!</p>
    <img src="./games/screenshot-urc.png" alt = "ultimate rick quest"/>
    <img src="./games/screenshot-ps.png" alt = "particle sandbox"/>
    <img src="./games/screenshot-ms.png" alt = "minesweeper classic"/>
    <img src="./games/screenshot-fb.png" alt = "flappy bird"/>
</div>

<style>
    #main {
        width: 1000px;
        height: 500px;
        overflow-y: scroll;
        background-image: url('/backgrounds/water.jpg');
        background-size: 15vw;
        color: white;
    }
    img {
        width: 400px;
    }
</style>