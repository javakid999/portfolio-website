<script lang="ts">
  import Navbar from "./lib/Navbar.svelte";
  import Home from "./lib/Home.svelte";

  let isShown = false;
</script>

<main>
  <div id='browser-container'>
    <img id="spotlight-overlay" class:shown={isShown} src="./spotlight.svg" alt="cringus"/>
    <Navbar></Navbar>  
    <div id="main-window">
      <Home></Home>
    </div>
    <div id="nav-deco-bottom">
      <div id="music-player">
        <audio id='player' autoplay controls src="fs1.mp3"></audio>
      </div>
      <div id="donate-button" tabindex="0" role="button" on:mouseenter={() => isShown=true} on:mouseleave={() => isShown=false}>
        <img src="./money.gif" style="image-rendering: pixelated; width: 4em; height: 4em;" alt="penis" />
      </div>
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
    flex: 1;
  }
  #nav-deco-bottom {
    width: 100%;
    display: flex;
    margin-top: auto;
    align-self: flex-end;
  }
  #music-player {
    align-self: flex-start;
    margin: auto auto auto 0;
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
    to {transform: translate(-34%, -38%)}
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
    transform: translate(-34%, -38%);
    opacity: 1;
  }
  #donate-button:hover {
    animation: bounce 0.3s cubic-bezier(.67,0,.25,1) infinite;
  }
  #donate-button img {
    animation: rainbow 2s infinite;
  }
</style>