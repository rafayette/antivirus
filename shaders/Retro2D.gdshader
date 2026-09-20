shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float pixel_size : hint_range(1.0, 20.0, 1.0) = 4.0;
uniform float levels : hint_range(1.0, 100.0, 1.0) = 8.0;
uniform vec2 gamma = vec2(1.0, 1.0);
uniform float temperature: hint_range(40.0, 130.0, 1.0);
uniform sampler2D noise_texture : repeat_enable;
uniform float haze_strength : hint_range(0.0, 0.05) = 0.01;

void fragment() {
	float intensity = smoothstep(75.0, 115.0, temperature);
	
	vec2 noise_uv = SCREEN_UV + vec2(0.0, TIME * 0.1);
	vec2 noise_vec = texture(noise_texture, noise_uv).rg - vec2(0.5);
	vec2 haze_offset = noise_vec * haze_strength * intensity * (1.0 - SCREEN_UV.y);
	vec2 distorted_uv = SCREEN_UV + haze_offset;
	
	vec2 tex_size = vec2(textureSize(screen_texture, 0));
	vec2 pixel_count = tex_size / pixel_size;
	vec2 pixelated_uv = floor(distorted_uv * pixel_count) / pixel_count;
	vec4 color = texture(screen_texture, pixelated_uv);
	
	float dist_from_center = distance(SCREEN_UV, vec2(0.5));
	float vignette_mask = smoothstep(0.25, 0.70, dist_from_center);
	vec3 glow_color = vec3(1.0, 0.35, 0.0);
	float vignette_factor = vignette_mask * intensity;
	float global_tint_factor = intensity * 0.3;
	color.rgb = mix(color.rgb, color.rgb + glow_color * 0.5, global_tint_factor);
	color.rgb = mix(color.rgb, color.rgb + glow_color * 1.5, vignette_factor);
	
	//if (intensity > 0.0) {
	//	color.r += intensity * 2.0;
	//	color.r *= (1.0 + intensity);
	//}
	//color.rgb = pow(color.rgb, vec3(gamma.x));
	
	float grayscale = max(color.r, max(color.g, color.b));
	if (grayscale > 0.0) {
		float lower = floor(grayscale * levels) / levels;
		float higher = ceil(grayscale * levels) / levels;
		
		float lower_diff = abs(lower - grayscale);
		float higher_diff = abs(higher - grayscale);
		
		float level = lower_diff < higher_diff ? lower : higher;
		float adjustment = level / grayscale;
		color.rgb *= adjustment;
	}
	
	color.rgb = pow(color.rgb, vec3(gamma.y));
	
	COLOR = color;
}