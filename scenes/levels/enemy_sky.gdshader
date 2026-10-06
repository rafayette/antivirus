shader_type sky;

uniform sampler2D boss_texture : source_color, filter_nearest;
uniform float cell_count : hint_range(2.0, 30.0) = 10.0;
uniform float reveal_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec3 dark_tint : source_color = vec3(0.15, 0.05, 0.1);

// crystallization params, same as your existing sky shader
uniform vec3 crystal_color_a : source_color = vec3(0.1, 0.8, 1.0);
uniform vec3 crystal_color_b : source_color = vec3(0.4, 0.1, 0.9);
uniform vec3 crystal_bg : source_color = vec3(0.0, 0.02, 0.05);
uniform float crystal_scale : hint_range(1.0, 30.0) = 8.0;
uniform float edge_sharpness : hint_range(1.0, 50.0) = 20.0;
uniform float crystal_anim_speed : hint_range(0.0, 1.0) = 0.05;

uniform float sprite_spin_speed : hint_range(-2.0, 2.0) = 0.2;

vec3 rotate_y(vec3 v, float angle) {
	float s = sin(angle);
	float c = cos(angle);
	return vec3(
		v.x * c + v.z * s,
		v.y,
		-v.x * s + v.z * c
	);
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

vec2 hash2(vec2 p) {
	p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
	return fract(sin(p) * 43758.5453);
}

float voronoi(vec2 uv) {
	vec2 cell = floor(uv);
	vec2 frac_uv = fract(uv);
	float min_dist = 1.0;
	float second_min = 1.0;
	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 neighbor = vec2(float(x), float(y));
			vec2 point = hash2(cell + neighbor);
			point = 0.5 + 0.5 * sin(TIME * crystal_anim_speed + 6.2831 * point);
			vec2 diff = neighbor + point - frac_uv;
			float dist = length(diff);
			if (dist < min_dist) {
				second_min = min_dist;
				min_dist = dist;
			} else if (dist < second_min) {
				second_min = dist;
			}
		}
	}
	return second_min - min_dist;
}

vec3 get_crystal_color(vec3 dir) {
	vec2 uv = vec2(atan(dir.z, dir.x), acos(dir.y)) * crystal_scale;
	float edge = voronoi(uv);
	float facet_mask = smoothstep(0.0, 1.0 / edge_sharpness, edge);
	vec2 cell_id = hash2(floor(uv));
	vec3 facet_color = mix(crystal_color_a, crystal_color_b, cell_id.x);
	vec3 final_color = mix(facet_color, crystal_bg, facet_mask);
	float horizon_fade = smoothstep(-0.3, 0.3, dir.y);
	return final_color * mix(0.3, 1.0, horizon_fade);
}

void sky() {
	vec3 dir = EYEDIR;
	vec3 crystal_result = get_crystal_color(dir);
	
	vec3 spin_dir = rotate_y(dir, TIME * sprite_spin_speed);
	vec2 uv = vec2(atan(spin_dir.z, spin_dir.x) / (2.0 * PI) + 0.5, acos(spin_dir.y) / PI);
	uv *= cell_count;
	vec2 cell_id = floor(uv);
	vec2 cell_uv = fract(uv);
	float threshold = hash(cell_id);
	
	if (threshold < reveal_amount) {
		vec4 tex = texture(boss_texture, cell_uv);
		vec3 darkened = tex.rgb * dark_tint;
		COLOR = mix(crystal_result, darkened, tex.a);
	} else {
		COLOR = crystal_result;
	}
}