shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float strength : hint_range(0.0, 1.0) = 0.0;
uniform float seed = 0.0;

float hash(float n) {
	return fract(sin(n) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	float band = floor(uv.y * 28.0);
	float tear = step(0.65, hash(band * 1.7 + seed));
	uv.x += (hash(band + seed) - 0.5) * 0.12 * strength * tear;
	float split = 0.014 * strength;
	vec3 color = vec3(
		texture(screen_texture, uv + vec2(split, 0.0)).r,
		texture(screen_texture, uv).g,
		texture(screen_texture, uv - vec2(split, 0.0)).b
	);
	float scan = 1.0 - 0.2 * strength * step(0.5, fract(SCREEN_UV.y * 220.0));
	float noise = (hash(dot(floor(SCREEN_UV * vec2(320.0, 180.0)), vec2(12.9898, 78.233)) + seed) - 0.5) * 0.25 * strength;
	COLOR = vec4(color * scan + noise, 1.0);
}
