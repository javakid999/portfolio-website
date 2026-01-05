<script lang="ts">
    let music_player: HTMLAudioElement;
    let current_song: string;
    let current_song_name = 'Macintosh Plus - ブート';
    let current_song_bpm = 69;
    let song_selector: HTMLSelectElement;
    let audioVis: HTMLCanvasElement;
    let visMode = 1;

    const song_url_lookup: {[key: string]: string} = {
      "1":  "./music/01.ogg",
      "2":  "./music/02.ogg",
      "3":  "./music/03.flac",
      "4":  "./music/04.flac",
      "5":  "./music/05.flac",
      "6":  "./music/06.flac",
      "7":  "./music/07.mp3",
      "8":  "./music/08.wav",
      "9":  "./music/09.m4a",
      "10": "./music/10.mp3",
      "11": "./music/11.mp3",
      "12": "./music/12.wav",
      "13": "./music/13.wav",
      "14": "./music/14.flac",
      "15": "./music/15.flac",
      "16": "./music/16.flac",
    };

    const bpms: {[key: string]: number} = {
        "1":  69,
        "2":  88,
        "3":  70,
        "4":  68,
        "5":  88,
        "6":  190,
        "7":  170,
        "8":  192,
        "9":  0,
        "10": 154,
        "11": 100,
        "12": 126,
        "13": 126,
        "14": 96,
        "15": 120,
        "16": 154,
    }

        function change_song() {
      music_player.src = song_url_lookup[current_song];
      current_song_name = 'Now Playing:' + song_selector.options[song_selector.selectedIndex].text;
      current_song_bpm = bpms[current_song];
    }

    function startVisualizer() {
      const audioCtx = new AudioContext();
      const ctx = audioVis.getContext('2d')!;

      const fftSize = 1024;

      const analyser = audioCtx.createAnalyser();
      const source = audioCtx.createMediaElementSource(music_player);
      source.connect(analyser);
      analyser.connect(audioCtx.destination);
      analyser.fftSize = fftSize;
      analyser.smoothingTimeConstant = 0.05;
      analyser.minDecibels = -80;
      const bufferLength = analyser.frequencyBinCount;
      const dataArray = new Uint8Array(bufferLength);

      let prev_bands = Array(32).fill(0);

      function render() {
        const beat = (music_player.currentTime * current_song_bpm / 60) % 1;
        const v = music_player.currentTime === 0 ? 0 : Math.pow(1-beat,2)*0.4
        ctx.clearRect(0, 0, audioVis.width, audioVis.height);
        ctx.fillStyle = 'white'
        ctx.globalAlpha = v;
        ctx.fillRect(0, 0, audioVis.width, audioVis.height);

        if (visMode == 0) {
          analyser.getByteTimeDomainData(dataArray);
          
          ctx.strokeStyle = 'white';
          ctx.globalAlpha = 1;
          ctx.lineWidth = 4;
          ctx.beginPath();

          let x = 0;
          for (let i = 0; i < dataArray.length; i+=4) {
            if (i === 0) {
              ctx.moveTo(x, dataArray[i] / 256 * audioVis.height);
            } else {
              ctx.lineTo(x, dataArray[i] / 256 * audioVis.height);
            }
            x += audioVis.width/dataArray.length*4;
          }
          ctx.stroke();
        } else {
          analyser.getByteFrequencyData(dataArray);
          
          const bands = 32;
          const bins_per = (dataArray.length-128)/bands;
          let current_bands = [];

          ctx.fillStyle = 'white';
          ctx.globalAlpha = 1;

          for (let i = 0; i < bands; i++) {
            let sum = 0;
            for (let j = 0; j < bins_per; j+=4) {
              sum += dataArray[i*bins_per+j]/255;
            }
            sum /= bins_per/4;
            const f = i*bins_per * audioCtx.sampleRate / fftSize;
            sum *= audioVis.height * 0.3 * Math.log10(f)
            ctx.fillRect(audioVis.width/bands*i, audioVis.height - Math.max(sum, prev_bands[i]), audioVis.width/bands, Math.abs(sum - prev_bands[i]) + 2);
            current_bands.push(sum);
          }
          prev_bands = [...current_bands];
        }

        requestAnimationFrame(render);
      }

      render();
    }
</script>

<div id="music-player">
  <audio id='player' controls src="fs1.mp3" bind:this={music_player} on:play={startVisualizer}></audio>
  <select id="song-selector" bind:value={current_song} on:change={change_song} bind:this={song_selector}>
    <optgroup label="Sick Tunez">
      <option value="1">Macintosh Plus - ブート</option>
      <option value="2">Macintosh Plus - リサフランク420 - 現代のコンピュー</option>
      <option value="3">Blank Banshee - B:/ Start Up</option>
      <option value="4">Blank Banshee - AMMONIA CLOUDS</option>
      <option value="5">2814 - 恢复</option>
      <option value="6">Maple - PAINT MY WALLS</option>
      <option value="7">Nightcore - Lucky Star</option>
      <option value="8">TheDJNightcore - Paradise on e</option>
      <option value="9">Nightcore - Anima Libera</option>
      <option value="10">Gasoiid - s0—n2u</option>
      <option value="11">Deaths Dynamic Shroud - PROMISE RING</option>
      <option value="12">2hollis - nerve (aiden* remix)</option>
      <option value="13">THE 1975 - IM IN LOVE WITH YOU (XAEV REMIX)</option>
      <option value="14">leroy - lil mama vip tickets</option>
      <option value="15">leroy - ricky bobby</option>
      <option value="16">leroy - the joke is on you</option>
    </optgroup>
  </select>
  <canvas id="audio-visualizer" bind:this={audioVis} on:click={() =>{visMode = visMode^1}}></canvas>
  <p id="current-song" class="wavy">
    {#each Array.from(current_song_name) as char, i}
      <span style="--i: {i}">
        {char === " " ? "\u00A0" : char}
      </span>
    {/each}
  </p>
</div>

<style>
  @font-face {
    font-family: Minecraft;
    src: url(./fonts/Minecraft.ttf)
  }
  #song-selector {
    color: #ffffff00;
    background: none;
    background-image: url('./musicgif.gif');
    image-rendering: pixelated;
    background-size: 100%;
    border: none;
    height: 32px;
    width: 60px;
  }
  #song-selector:hover {
    background-color: #00000050;
  }
  #song-selector:open {
    color: #000000;
  }
  #audio-visualizer {
    height: 3em;
  }
  #audio-visualizer:hover {
    background: #00000050;
  }
  @keyframes flash {
    0% {color:   hsla(0, 94%, 100%, 0.87);}
    50% {color:  hsla(0, 94%, 100%, 0.62);}
    100% {color: hsla(0, 94%, 100%, 0.87);}
  }
  @keyframes wave {
    0%   {transform: translateY(2px)}
    50%  {transform: translateY(-2px)}
    100% {transform: translateY(2px)}
  }
  #current-song {
    user-select: none;
    color: hsla(0, 94%, 100%, 0.87);
    animation: flash 5s infinite;
    font-family: Minecraft;
    text-shadow: black 2px 2px;
  }
  .wavy span {
    display: inline-block;
    position: relative;
    animation: wave 5s infinite;
    animation-delay: calc(-.2s * var(--i));
  }
  #music-player {
    display: flex;
    align-items: center;
    gap: 0.5em;
    padding: 5px;
    background-image: url('./backgrounds/waterfall.jpg');
    align-self: flex-start;
    margin: auto auto auto 0;
  }
</style>