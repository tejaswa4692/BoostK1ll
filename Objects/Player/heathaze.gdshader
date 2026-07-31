shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float haze_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float distortion_strength : hint_range(0.0, 0.05) = 0.008;
uniform float scroll_speed : hint_range(0.0, 5.0) = 1.5;
uniform float noise_scale : hint_range(1.0, 50.0) = 6.0;
uniform vec4 tint_color : source_color = vec4(1.0, 0.6, 0.3, 1.0);
uniform float tint_strength : hint_range(0.0, 0.3) = 0.05;
uniform float blur_amount : hint_range(0.0, 0.01) = 0.002;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float smooth_noise(vec2 p) {
	float n = noise(p) * 0.6;
	n += noise(p * 2.3 + vec2(17.0, 5.0)) * 0.3;
	n += noise(p * 4.7 + vec2(3.0, 29.0)) * 0.1;
	return n;
}

void fragment() {
	vec2 uv = SCREEN_UV;

	float t = TIME * scroll_speed;
	vec2 noise_uv = uv * noise_scale + vec2(0.0, -t);
	float n1 = smooth_noise(noise_uv);
	float n2 = smooth_noise(noise_uv * 1.7 + vec2(5.2, 1.3));

	vec2 offset = vec2(n1 - 0.5, n2 - 0.5) * distortion_strength * haze_intensity;
	vec2 distorted_uv = clamp(uv + offset, vec2(0.001), vec2(0.999));

	vec3 col = vec3(0.0);
	col += texture(screen_texture, distorted_uv).rgb * 0.4;
	col += texture(screen_texture, distorted_uv + vec2(blur_amount, 0.0)).rgb * 0.15;
	col += texture(screen_texture, distorted_uv - vec2(blur_amount, 0.0)).rgb * 0.15;
	col += texture(screen_texture, distorted_uv + vec2(0.0, blur_amount)).rgb * 0.15;
	col += texture(screen_texture, distorted_uv - vec2(0.0, blur_amount)).rgb * 0.15;

	col = mix(col, col * tint_color.rgb, tint_strength * haze_intensity);

	COLOR = vec4(col, 1.0);
}