export async function LoadImage(name: string, link: string) {
	const image = await new Promise((resolve, reject) => {
		const out = new Image();
		out.src = link;

		out.onerror = (err) => {
			reject(`Image ${link} failed to load: ${err}`);
		};

		out.onload = () => {
			resolve(out);
		};
	}).catch((err) => console.error(err));

	return {
		name,
		image
	};
}

export async function LoadProgram(name: string, link_v: string, link_f: string) {
	const vertex = await fetch(link_v).then(response => response.text());
    const fragment = await fetch(link_f).then(response => response.text());

	return {
		name,
		vertex,
        fragment
	};
}

export async function LoadSkybox(name: string, links: string[]) {
	const images = await Promise.all(
		links.map((link) => new Promise((resolve, reject) => {
			const image = new Image();
			image.src = link;

			image.onerror = (err) => {
				reject(`Image ${link} failed to load: ${err}`);
			};

			image.onload = () => {
				resolve(image);
			}
		}).catch((err) => console.error(err)))
	);

	return {
		name,
		images
	}
}

export interface ProgramSrc {
    vertex: string;
    fragment: string;
}