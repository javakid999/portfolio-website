<script lang="ts">
    import ReadingList from "./blog/ReadingList.svelte";
    import StaticWindow from "./StaticWindow.svelte";

    export let canvasManager;
    let viewportWidth: number, viewportHeight: number;
</script>

<div id="viewport-wrapper" bind:clientWidth={viewportWidth} bind:clientHeight={viewportHeight}>
    <div id="content">
        <h1><u>Blog</u></h1>
        <p>Welcome to the blog section of my website! Here is where you'll find some of my miscellaneous thoughts or projects that aren't fully deserving of their own page. I hope you enjoy! :) </p>
        <div id="blog-posts">
            <StaticWindow Title={"Reading List 2026"} id={1}>
                <ReadingList></ReadingList>
            </StaticWindow>
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
        height: 150%;
        image-rendering: pixelated;
        background:linear-gradient(rgba(0, 0, 0, 0.3), rgba(0, 0, 0, 0.3)), url('/backgrounds/library.png');
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
    #blog-posts {
    }
</style>