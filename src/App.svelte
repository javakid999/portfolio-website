<script lang="ts">
    import About from "./lib/About.svelte";
    import Atlas from "./lib/Atlas.svelte";
    import Blender from "./lib/Blender.svelte";
    import Blog from "./lib/Blog.svelte";
    import MusicPlayer from "./lib/home-screen/MusicPlayer.svelte";
    import Navbar from "./lib/home-screen/Navbar.svelte";
    import Home from "./lib/Home.svelte";
    import Portfolio from "./lib/Portfolio.svelte";

    export let canvasManager;

    let isShown = false;
    let mainWindow: HTMLDivElement;
    let page = Home;

    function changePage(event: any) {
        if (event.detail.page == "portfolio") {
            page = Portfolio;
        }
        if (event.detail.page == 'home') {
            page = Home;
        }
        if (event.detail.page == 'about') {
            page = About;
        }
        if (event.detail.page == 'blender') {
            page = Blender;
        }
        if (event.detail.page == 'blog') {
            page = Blog;
        }
        if (event.detail.page == 'atlas') {
            page = Atlas;
        }
    }
</script>

<main>
  <div id='browser-container'>
    <img id="spotlight-overlay" class:shown={isShown} src="./spotlight.svg" alt="cringus"/>
    <Navbar on:message={changePage}></Navbar>
    <div id="main-window" bind:this={mainWindow}>
      <svelte:component this={page} canvasManager={canvasManager} />
    </div>
    <div id="nav-deco-bottom">
      <MusicPlayer></MusicPlayer>
      <a href="https://ko-fi.com/orangelazer1" target="_blank"><div id="donate-button" tabindex="0" role="button" on:mouseenter={() => isShown=true} on:mouseleave={() => isShown=false}>
        <img src="./money.gif" style="image-rendering: pixelated; width: 4em; height: 4em;" alt="penis" />
      </div></a>
    </div>
  </div>
</main>

<style>
  #browser-container {
    padding: 0.8vh;
    height: 98.4vh;
    box-shadow: 3px 3px #ffffffbb inset, -3px -3px #00000044 inset;
    background-color: #d4d0c8;
    display: flex;
    flex-direction: column;
  }
  #main-window {
    text-align: center;
    overflow-y: auto;
  }
  #nav-deco-bottom {
    margin-top: auto;
    width: 100%;
    display: flex;
    align-self: flex-end;
  }
  
  @keyframes rainbow {
    0% {filter: hue-rotate(0)}
    100% {filter: hue-rotate(360deg)}
  }
  @keyframes bounce {
    0% {transform: translateY(0)}
    50% {transform: translateY(-20px)}
    100% {transform: translateY(0)}
  }
  @keyframes fade-in {
    from {opacity: 0}
    to {opacity: 1}
  }
  @keyframes move-in {
    from {transform: translate(-50%, -45%)}
    to {transform: translate(-34%, -30%)}
  }
  #spotlight-overlay {
    width: 200%;
    transform: translate(-50%, -45%);
    display: none;
    opacity: 0;
    position:absolute;
    user-select: none;
  }
  #spotlight-overlay.shown {
    display: block;
    animation: fade-in 0.2s linear 1, move-in 0.4s cubic-bezier(0,.68,.38,1) 1;
    transform: translate(-34%, -30%);
    opacity: 1;
  }
  #donate-button:hover {
    animation: bounce 0.3s cubic-bezier(.67,0,.25,1) infinite;
  }
  #donate-button img {
    animation: rainbow 2s infinite;
  }
</style>