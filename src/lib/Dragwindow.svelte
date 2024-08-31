<script lang="ts">
  import { afterUpdate, onMount } from "svelte";
  export let ParentWidth: number, ParentHeight: number;
  export let Title;
  export let id: number;

    onMount(() => {
        dragElement(document.getElementById(`window-${id}`)!);
        const elmnt = document.getElementById(`window-${id}`)!;
        elmnt.style.left = (Math.random() * 100).toString() + '%';
        elmnt.style.top = (Math.random() * 100).toString() + '%';
    });
    
    function dragElement(elmnt: HTMLElement) {
    var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
    document.getElementById(`window-${id}header`)!.onmousedown = dragMouseDown;

    function dragMouseDown(e: MouseEvent) {
        e = e || window.event;
        e.preventDefault();
        // get the mouse cursor position at startup:
        pos3 = e.clientX;
        pos4 = e.clientY;
        document.onmouseup = closeDragElement;
        // call a function whenever the cursor moves:
        document.onmousemove = elementDrag;
    }

    function elementDrag(e: MouseEvent) {
        e = e || window.event;
        e.preventDefault();
        // calculate the new cursor position:
        pos1 = pos3 - e.clientX;
        pos2 = pos4 - e.clientY;
        pos3 = e.clientX;
        pos4 = e.clientY;
        if (elmnt.offsetLeft < 0 || elmnt.offsetTop < 0) {
            elmnt.style.left = (parseInt(elmnt.style.left) - (elmnt.offsetLeft < 0 ? elmnt.offsetLeft : 0)).toString();
            elmnt.style.top = (parseInt(elmnt.style.top) - (elmnt.offsetTop < 0 ? elmnt.offsetTop : 0)).toString();
        }
        if (elmnt.offsetLeft+elmnt.clientWidth > ParentWidth) {
            elmnt.style.left = (ParentWidth-elmnt.clientWidth).toString()+'px';
        } 
        if (elmnt.offsetTop+elmnt.clientHeight > ParentHeight) {
            elmnt.style.top = (ParentHeight-elmnt.clientHeight).toString()+'px';
        }
        elmnt.style.top = (elmnt.offsetTop - pos2) + "px";
        elmnt.style.left = (elmnt.offsetLeft - pos1) + "px";
    }

    function closeDragElement() {
        // stop moving when mouse button is released:
        document.onmouseup = null;
        document.onmousemove = null;
    }
    }
</script>

<div id="window-{id}" class="dragwindow">
    <div id="window-{id}header" class="dragwindowheader" role="button" tabindex="0">
        <div id="nav-deco-top">
            <span id="version">
                <p>{Title}</p>
            </span>
            <span id="window-buttons">
                <span id="minimize" class="window-button">
                <img src="./icons/down.png" style="image-rendering: pixelated; width: 1.5em; height: 1.5em;" alt="minimize" />
                </span>
                <span id="fullscreen" class="window-button">
                <img src="./icons/updown.png" style="image-rendering: pixelated; width: 1.5em; height: 1.5em;" alt="fullscreen" />
                </span>
            </span>
        </div>
    </div>
    <slot></slot>
</div>

<style>
    .dragwindow {
        position: absolute;
        z-index: 9;
        padding: 0.5vh;
        box-shadow: 3px 3px #ffffffbb inset, -3px -3px #00000044 inset;
        background-color: #d4d0c8;
    }
    .dragwindowheader {
        cursor: move;
        z-index: 10;
    }
    #nav-deco-top {
        background: rgb(0,27,130);
        color: #ffffff;
        user-select: none;
        display: flex;
        align-items: center;
        background: linear-gradient(90deg, rgba(0,27,130,1) 0%, rgba(178,238,255,1) 100%); 
    }
    #version p {
        margin: 0.2em;
        margin-left: 0.4em;
        font-size: 0.8em;
        text-align: center;
    }
    #window-buttons {
        align-self: flex-end;
        margin: 0 0 0 auto;
        display: flex;
        height: 1.5em;
        width: 3em;
        overflow: hidden;
    }
    .window-button img {
        margin: 0;
    }
</style>