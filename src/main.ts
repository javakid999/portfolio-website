import './app.css';
import App from './App.svelte';
import { CanvasManager } from './lib/canvasManager';
import { LoadImage, LoadProgram, type ProgramSrc } from './util/load';

(async () => {
      let manifest = await fetch('./src/assets/assets.json').then((x) => x.json());
      let imageArr = await Promise.all(manifest.images.map(({name, link}: {[index: string]: string}): any => LoadImage(name, link)));
      let programArr = await Promise.all(manifest.shaders.map(({name, link_v, link_f}: {[index: string]: string}): any => LoadProgram(name, link_v, link_f)));

      const assets: {[id: string]: HTMLImageElement} = {};
      const programs: {[id: string]: ProgramSrc} = {};
      imageArr.forEach(({ name, image }) => assets[name] = image);
      programArr.forEach(({ name, vertex, fragment }) => programs[name] = {vertex: vertex, fragment: fragment})

      const canvasManager = new CanvasManager(programs, assets);

      const app = new App({
        target: document.getElementById('app')!,
        props: {
          canvasManager: canvasManager
        }
      })
})();