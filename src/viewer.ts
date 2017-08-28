import { Options, options as _options } from './options';
import { createRenderer } from './renderer';
import { Scene } from './scene';

export function createViewer(
	element: HTMLElement,
	scene: Scene,
	options?: Options) {

	options = options || _options();

	const canvas = document.createElement("canvas");
	canvas.width = options.width;
	canvas.height = options.height;
	element.appendChild(canvas);

	const gl = canvas.getContext("webgl", {
		preserveDrawingBuffer: true
	});
	if (gl === null)
		return null;

	const variables = {
		time: 0,
		clicked: false,
		mouse: { x: 0.0, y: 0.0 }
	};

	const renderer = createRenderer(gl, scene, options, variables);

	canvas.addEventListener("click", event => {
		if (!event.altKey)
			return;
		const link = document.createElement("a");
		link.setAttribute("download", "render.png");
		link.setAttribute("href", canvas.toDataURL());
		link.click();
	});

	canvas.addEventListener("mousedown", () => variables.clicked = true);
	document.addEventListener("mouseup", () => variables.clicked = false);

	canvas.addEventListener("mousemove", event => {
		if (variables.clicked) {
			variables.mouse.x += event.movementX / canvas.clientWidth;
			variables.mouse.y += -event.movementY / canvas.clientHeight;
		}
	});

	let start = 0;

	function loop(time: number) {
		if (!start) start = time;
		variables.time = (time - start) / 1000.0;

		renderer.render();

		requestAnimationFrame(loop);
	}

	requestAnimationFrame(loop);
}