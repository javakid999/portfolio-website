<script>
    import { createEventDispatcher } from "svelte";

   const dispatch = createEventDispatcher();
   
    function swtichPortfolio() {
        dispatch('message', {
            page: 'portfolio'
        });
    }

    function switchHome() {
        dispatch('message', {
            page: 'home'
        })
    }

    function switchAbout() {
        dispatch('message', {
            page: 'about'
        });
    }

    function switchBlender() {
        dispatch('message', {
            page: 'blender'
        });
    }

    function switchAtlas() {
        dispatch('message', {
            page: 'atlas'
        });
    }

    function switchBlog() {
        dispatch('message', {
            page: 'blog'
        })
    }
</script>

<div id="main">
    <div id="nav-deco-top">
        <span id="fav">
            <img src="./icons/fav.png" style="image-rendering: pixelated; width: 2em; height: 2em; object-fit: cover; object-position: 0% 0%;" alt="favicon"/>
        </span>
        <span id="version">
            <p>Version 4.2 - Navscape Navigator 1999</p>
        </span>
        <span id="window-buttons">
            <span id="minimize" class="window-button">
            <img src="./icons/down.png" style="image-rendering: pixelated; width: 2em; height: 2em;" alt="minimize" />
            </span>
            <span id="fullscreen" class="window-button">
            <img src="./icons/updown.png" style="image-rendering: pixelated; width: 2em; height: 2em;" alt="fullscreen" />
            </span>
        </span>
    </div>
        <div id="nav-deco-menu">
        <span id="file-button">
            <button class="nav-deco-button"><u>Fi</u>le</button>
        </span>
        <span id="edit-button">
            <button class="nav-deco-button"><u>Ed</u>it</button>
        </span>
        <span id="view-button">
            <button class="nav-deco-button"><u>Vi</u>ew</button>
        </span>
        <span id="go-button">
            <button class="nav-deco-button"><u>G</u>o</button>
        </span>
        <span id="communicator-button">
            <button class="nav-deco-button"><u>Com</u>municator</button>
        </span>
        <span id="help-button">
            <button class="nav-deco-button"><u>He</u>lp</button>
        </span>
        </div>
    
        <div id="navbar">
        <span id="navbar-options">
            <!-- svelte-ignore a11y-click-events-have-key-events -->
            <span class="navbar-item" id="navbar-home" on:click={switchHome} tabindex="0" role="button">
            <img src="./icons/home_button.png" style="image-rendering: pixelated; width: 3em; height: 3em;" alt="home button" />
            <p>Home</p>
            </span>

            <span class="navbar-item" id="navbar-music">
            <img src="./icons/music_button.png" style="image-rendering: pixelated; width: 3em; height: 3em;" alt="music button" />
            <p>Music</p>
            </span>

            <!-- svelte-ignore a11y-click-events-have-key-events -->
            <span class="navbar-item" id="navbar-blender" on:click={switchBlender} tabindex="0" role="button">
            <img src="./icons/blender_button.png" style="image-rendering: pixelated; width: 3em; height: 3em;" alt="blender button" />
            <p>3D Art</p>
            </span>

            <!-- svelte-ignore a11y-click-events-have-key-events -->
            <span class="navbar-item" id="navbar-about" on:click={switchAbout} tabindex="0" role="button">
            <img src="./icons/about_button.png" style="image-rendering: pixelated; width: 3em; height: 3em;" alt="about button" />
            <p>About</p>
            </span>

            <!-- svelte-ignore a11y-click-events-have-key-events -->
            <span class="navbar-item" id="navbar-portfolio" on:click={swtichPortfolio} tabindex="0" role="button">
                <img src="./icons/portfolio_button.png" style="image-rendering: pixelated; width: 3em; height: 3em;" alt="portfolio button" />
                <p>Portfolio</p>
            </span>

            <!-- svelte-ignore a11y-click-events-have-key-events -->
            <span class="navbar-item" id="navbar-blog" on:click={switchBlog} tabindex="0" role="button">
            <img src="./icons/blog.png" style="image-rendering: pixelated; width: 3em; height: 3em;" alt="atlas button" />
            <p>Blog</p>
            </span>

            <!-- svelte-ignore a11y-click-events-have-key-events -->
            <span class="navbar-item" id="navbar-atlas" on:click={switchAtlas} tabindex="0" role="button">
            <img src="./icons/atlas_icon.png" style="image-rendering: pixelated; width: 3em; height: 3em;" alt="atlas button" />
            <p>Atlas</p>
            </span>
        </span>
            <span id="navbar-icon">
                <a href="https://linktr.ee/orangelazer" target="_blank">
                <img src="./icons/profile_pic.jpg" style="image-rendering: pixelated; width: 4em; height: 4em;" alt="profile pic" />
                </a>
            <span/>
    </div>
</div>

<style>
    #nav-deco-top {
        background: rgb(0,27,130);
        color: #ffffff;
        user-select: none;
        display: flex;
        align-items: center;
        background: linear-gradient(90deg, rgba(0,27,130,1) 0%, rgba(178,238,255,1) 100%); 
    }
    .nav-deco-button {
        background-color: #00000000;
        border: none;
        font-family: 'Times New Roman', Times, serif;
    }
    .nav-deco-button:hover {
        background-color: #00000044;
        cursor: pointer;
    }
    #nav-deco-menu {
        background: #D4D0C8;
        user-select: none;
    }
    #fav {
        height: 2em;
    }
    #version p {
        margin: 0 auto 0 0;
    }
    #window-buttons {
        align-self: flex-end;
        margin: 0 0 0 auto;
        display: flex;
        height: 2em;
        width: 4em;
        overflow: hidden;
    }
    .window-button {
        height: 2em;
        width: 2em;
    }
    .window-button img {
        margin: 0;
    }
    #navbar {
        background: #D4D0C8;
        height: 5em;
        display: flex;
        align-items: center;
    }
    #navbar-options {
        margin: 0 auto 0 0;
        display: flex;
    }
    @keyframes bounce-start {
        0%   {transform: rotate(0)}
        100% {transform: rotate(-10deg)}
    }
    @keyframes bounce-loop {
        0% {transform: rotate(-10deg)}
        50% {transform: rotate(10deg)}
        100% {transform: rotate(-10deg)}
    }
    .navbar-item {
        margin: 0 2em;
        user-select: none;
    }
    .navbar-item:hover {
        animation-name: bounce-start, bounce-loop;
        animation-duration: 1.25s, 2.5s;
        animation-iteration-count: 1, infinite;
        animation-delay: 0s, 1.25s;
    }
    .navbar-item:active {
        animation: bounce 1s cubic-bezier(.67,0,.25,1) infinite;
    }
    .navbar-item p {
        margin: 0;
    }
    @keyframes bounce {
        0% {transform: translateY(0)}
        50% {transform: translateY(-20px)}
        100% {transform: translateY(0)}
    }
    @keyframes flip {
        0% {transform: rotate3d(1,0.5,1,0)}
        50% {transform: rotate3d(1,0.5,1,180deg)}
        100% {transform: rotate3d(1,0.5,1,360deg)}
    }
    @keyframes flip-return {
        to {transform: rotate3d(1, 0.5, 1, 0)}
    }
    @keyframes gentle-spin {
        0% {transform: rotate3d(1,0,0,-30deg)}
        25% {transform: rotate3d(0,1,0,-30deg)}
        50% {transform: rotate3d(1,0,0,30deg)}
        75% {transform: rotate3d(0,1,0,30deg)}
        100% {transform: rotate3d(1,0,0,-30deg)}
    }
    #navbar-icon {
        align-self: flex-end;
        margin: auto 0.5em auto auto;
        animation: flip 3s linear infinite;
    }  
    #navbar-icon:hover {
        animation-iteration-count: 0;
        animation: gentle-spin 2s linear infinite;
    }
    #navbar-icon img {
        border-radius: 1em;
    }  
</style>
