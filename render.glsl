precision highp float;

uniform sampler2D texture;
uniform vec2 resolution;
uniform float time;
varying vec2 uv;

const float PI = 3.14159;
const float MAX_VALUE = 1e30;

const float epsilon = 0.01;
const int maxSteps = 64;
const int bounces = 12;

const vec3 target = vec3(0, 0, 0);
const vec3 eye = vec3(9, 15, 9);

const float field = PI / 4.0;
const float focal = length(target - eye);
const float aperture = 0.05 * focal;
const vec3 look = normalize(target - eye);
const vec3 qup = vec3(0, 1, 0);
const vec3 up = qup - look * dot(look, qup);
const vec3 right = cross(look, up);

vec2 random(int seed) {
	vec2 s = uv * (1.0 + time + float(seed));
	// implementation based on: lumina.sourceforge.net/Tutorials/Noise.html
	return vec2(
		fract(sin(dot(s.xy, vec2(12.9898, 78.233))) * 43758.5453),
		fract(cos(dot(s.xy, vec2(4.898, 7.23))) * 23421.631));
}

vec3 ortho(vec3 v) {
	//  See : http://lolengine.net/blog/2013/09/21/picking-orthogonal-vector-combing-coconuts
	return abs(v.x) > abs(v.z) ? vec3(-v.y, v.x, 0.0) : vec3(0.0, -v.z, v.y);
}

vec3 wobble(vec3 normal, float smoothness, vec2 noise) {
	vec3 o1 = normalize(ortho(normal));
	vec3 o2 = normalize(cross(normal, o1));
	noise.x *= 2.0 * PI;
	noise.y = sqrt(smoothness + (1.0 - smoothness) * noise.y);
	float q = sqrt(1.0 - noise.y * noise.y);
	return q * (cos(noise.x) * o1  + sin(noise.x) * o2) + noise.y * normal;
}

float sphereDistance3(vec3 position) {
	return length(position) - 2.0;
}

float sphereDistance2( vec3 p )
{
vec2 t = vec2(6.0, 1.0);
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

float sphereDistance1(vec3 position) {
	return length(position) - 0.45;
}

float sphereDistance(vec3 position) {
	position.x = mod(position.x, 1.0) - 0.5;
	position.z = mod(position.z, 1.0) - 0.5;
	return sphereDistance1(position);
}

vec3 sphereNormal(vec3 position) {
	return normalize(vec3(
		sphereDistance(position + vec3(epsilon, 0, 0)) -
		sphereDistance(position - vec3(epsilon, 0, 0)),
		sphereDistance(position + vec3(0, epsilon, 0)) -
		sphereDistance(position - vec3(0, epsilon, 0)),
		sphereDistance(position + vec3(0, 0, epsilon)) -
		sphereDistance(position - vec3(0, 0, epsilon))));
}

vec3 sphereNormal2(vec3 position) {
	return normalize(vec3(
		sphereDistance2(position + vec3(epsilon, 0, 0)) -
		sphereDistance2(position - vec3(epsilon, 0, 0)),
		sphereDistance2(position + vec3(0, epsilon, 0)) -
		sphereDistance2(position - vec3(0, epsilon, 0)),
		sphereDistance2(position + vec3(0, 0, epsilon)) -
		sphereDistance2(position - vec3(0, 0, epsilon))));
}

vec3 sphereNormal3(vec3 position) {
	return normalize(vec3(
		sphereDistance3(position + vec3(epsilon, 0, 0)) -
		sphereDistance3(position - vec3(epsilon, 0, 0)),
		sphereDistance3(position + vec3(0, epsilon, 0)) -
		sphereDistance3(position - vec3(0, epsilon, 0)),
		sphereDistance3(position + vec3(0, 0, epsilon)) -
		sphereDistance3(position - vec3(0, 0, epsilon))));
}

float plane1Distance(vec3 position) {
	return dot(position, vec3(0, 1, 0)) + 0.0;
}

vec3 plane1Normal(vec3 position) {
	return normalize(vec3(
		plane1Distance(position + vec3(epsilon, 0, 0)) -
		plane1Distance(position - vec3(epsilon, 0, 0)),
		plane1Distance(position + vec3(0, epsilon, 0)) -
		plane1Distance(position - vec3(0, epsilon, 0)),
		plane1Distance(position + vec3(0, 0, epsilon)) -
		plane1Distance(position - vec3(0, 0, epsilon))));
}

float plane2Distance(vec3 position) {
	return dot(position, vec3(0, -1, 0)) + 100.0;
}

vec3 plane2Normal(vec3 position) {
	return normalize(vec3(
		plane2Distance(position + vec3(epsilon, 0, 0)) -
		plane2Distance(position - vec3(epsilon, 0, 0)),
		plane2Distance(position + vec3(0, epsilon, 0)) -
		plane2Distance(position - vec3(0, epsilon, 0)),
		plane2Distance(position + vec3(0, 0, epsilon)) -
		plane2Distance(position - vec3(0, 0, epsilon))));
}

float plane3Distance(vec3 position) {
	return dot(position, vec3(0, 0, 1)) + 100.0;
}

vec3 plane3Normal(vec3 position) {
	return normalize(vec3(
		plane3Distance(position + vec3(epsilon, 0, 0)) -
		plane3Distance(position - vec3(epsilon, 0, 0)),
		plane3Distance(position + vec3(0, epsilon, 0)) -
		plane3Distance(position - vec3(0, epsilon, 0)),
		plane3Distance(position + vec3(0, 0, epsilon)) -
		plane3Distance(position - vec3(0, 0, epsilon))));
}

float plane4Distance(vec3 position) {
	return dot(position, vec3(0, 0, -1)) + 100.0;
}

vec3 plane4Normal(vec3 position) {
	return normalize(vec3(
		plane4Distance(position + vec3(epsilon, 0, 0)) -
		plane4Distance(position - vec3(epsilon, 0, 0)),
		plane4Distance(position + vec3(0, epsilon, 0)) -
		plane4Distance(position - vec3(0, epsilon, 0)),
		plane4Distance(position + vec3(0, 0, epsilon)) -
		plane4Distance(position - vec3(0, 0, epsilon))));
}

float plane5Distance(vec3 position) {
	return dot(position, vec3(-1, 0, 0)) + 100.0;
}

vec3 plane5Normal(vec3 position) {
	return normalize(vec3(
		plane5Distance(position + vec3(epsilon, 0, 0)) -
		plane5Distance(position - vec3(epsilon, 0, 0)),
		plane5Distance(position + vec3(0, epsilon, 0)) -
		plane5Distance(position - vec3(0, epsilon, 0)),
		plane5Distance(position + vec3(0, 0, epsilon)) -
		plane5Distance(position - vec3(0, 0, epsilon))));
}

float plane6Distance(vec3 position) {
	return dot(position, vec3(1, 0, 0)) + 100.0;
}

vec3 plane6Normal(vec3 position) {
	return normalize(vec3(
		plane6Distance(position + vec3(epsilon, 0, 0)) -
		plane6Distance(position - vec3(epsilon, 0, 0)),
		plane6Distance(position + vec3(0, epsilon, 0)) -
		plane6Distance(position - vec3(0, epsilon, 0)),
		plane6Distance(position + vec3(0, 0, epsilon)) -
		plane6Distance(position - vec3(0, 0, epsilon))));
}

void main() {
	float aspectRatio = resolution.x / resolution.y;
	vec2 noise = random(0);

	vec2 origin = noise.x * aperture * vec2(cos(noise.y * 2.0 * PI), sin(noise.y * 2.0 * PI));

	vec2 px = uv + (noise * 2.0 - 1.0) / resolution.x;
	vec3 screen = eye + (look + tan(field) * (px.x * aspectRatio * right + px.y * up)) * focal;

	vec3 from = eye + right * origin.x + up * origin.y;
	vec3 direction = normalize(screen - from);

	vec3 luminance = vec3(1, 1, 1);
	vec3 total = vec3(0, 0, 0);

	for (int k = 1; k <= bounces; k++) {
		float t = 0.0;
		int i = 0;
		vec3 position = from;

		for (int j = 1; j <= maxSteps; j++) {
			float minimum = MAX_VALUE;
			float distance;

			distance = abs(plane1Distance(position));
			if (distance < minimum) {
				minimum = distance;
				i = 1;
			}

			distance = abs(plane2Distance(position));
			if (distance < minimum) {
				minimum = distance;
				i = 2;
			}

			distance = abs(plane3Distance(position));
			if (distance < minimum) {
				minimum = distance;
				i = 3;
			}

			distance = abs(plane4Distance(position));
			if (distance < minimum) {
				minimum = distance;
				i = 4;
			}

			distance = abs(plane5Distance(position));
			if (distance < minimum) {
				minimum = distance;
				i = 5;
			}

			distance = abs(plane6Distance(position));
			if (distance < minimum) {
				minimum = distance;
				i = 6;
			}

			distance = abs(sphereDistance2(position));
			if (distance < minimum) {
				minimum = distance;
				i = 7;
			}

			distance = abs(sphereDistance(position));
			if (distance < minimum) {
				minimum = distance;
				i = 8;
			}

			distance = abs(sphereDistance3(position));
			if (distance < minimum) {
				minimum = distance;
				i = 9;
			}

		 	t += minimum;
			position = from + direction * t;

			if (minimum < epsilon)
				break;

			t -= epsilon;
		}

		from = position;

		if (i == 0)
			break;

		vec3 normal;

		if (i == 1)
			normal = plane1Normal(position);
		else if (i == 2)
			normal = plane2Normal(position);
		else if (i == 3)
			normal = plane3Normal(position);
		else if (i == 4)
			normal = plane4Normal(position);
		else if (i == 5)
			normal = plane5Normal(position);
		else if (i == 6)
			normal = plane6Normal(position);
		else if (i == 7)
			normal = sphereNormal2(position);
		else if (i == 8)
			normal = sphereNormal(position);
		else if (i == 9) {
			normal = sphereNormal3(position);
		}

		float transmittance = 0.0;
		float smoothness = 0.0;
		float refraction = 1.0;
		vec3 color = vec3(1, 1, 1);
		vec3 emissive = vec3(0, 0, 0);

		if (i >= 1 && i <= 6) {
			color = vec3(1, 1, 1) * 0.8;
		}

		if (i == 2) {
			emissive = vec3(1, 1, 1) * 2.0;
			color = vec3(0, 0, 0);
		}

		if (i == 7) {
			transmittance = 0.98;
			smoothness = 0.5;
			color = vec3(0.8, 0.8, 1.0);
			refraction = 1.4;
		}

		if (i == 8) {
			color = vec3(1, 1, 1) * 0.9;
		}

		if (i == 9) {
			smoothness = 0.9;
			color = vec3(1.0, 0.6, 0.6) * 0.9;
		}

		if (dot(normal, direction) > 0.0)
			normal = -normal;

		total += luminance * emissive;
		luminance = luminance * color;

		vec2 noise = random(k);

		normal = wobble(normal, smoothness, noise);

		if (noise.y < transmittance) {
			from = from - normal * epsilon;
			direction = refract(direction, normal, 1.0 / refraction);
		} else {
			from = from + normal * epsilon;
			direction = reflect(direction, normal);
		}
	}

	vec4 original = texture2D(texture, uv * 0.5 - 0.5);
	gl_FragColor = vec4(original.xyz + total, original.w + 1.0);
}