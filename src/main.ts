import './app.css';
import App from './App.svelte';
import { CanvasManager } from './lib/canvasManager';
import { LoadImage, LoadProgram, LoadSkybox, type ProgramSrc } from './util/load';

(async () => {
      let manifest = await fetch('assets/assets.json').then((x) => x.json());
      let imageArr = await Promise.all(manifest.images.map(
        ({name, link}: {[index: string]: string}): any => LoadImage(name, link)
      ));
      let programArr = await Promise.all(manifest.shaders.map(
        ({name, link_v, link_f}: {[index: string]: string}): any => LoadProgram(name, link_v, link_f)
      ));
      let skyboxArr = await Promise.all(manifest.skyboxes.map(
        ({name, links}: {name: string, links: string[]}): any => LoadSkybox(name, links)
      ))

      const assets: {[id: string]: HTMLImageElement} = {};
      const programs: {[id: string]: ProgramSrc} = {};
      const skyboxes: {[id: string]: HTMLImageElement[]} = {};
      imageArr.forEach(({ name, image }) => assets[name] = image);
      programArr.forEach(({ name, vertex, fragment }) => programs[name] = {vertex: vertex, fragment: fragment})
      skyboxArr.forEach(({name, images}) => skyboxes[name] = images)

      const canvasManager = new CanvasManager(programs, assets, skyboxes);

      const app = new App({
        target: document.getElementById('app')!,
        props: {
          canvasManager: canvasManager
        }
      })
})();