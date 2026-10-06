shader_type sky;

uniform vec3 crystal_color_a : source_color = vec3(0.1, 0.8, 1.0);
uniform vec3 crystal_color_b : source_color = vec3(0.4, 0.1, 0.9);
uniform vec3 bg_color : source_color = vec3(0.0, 0.02, 0.05);
uniform float cell_scale : hint_range(1.0, 30.0) = 8.0;
uniform float edge_sharpness : hint_range(1.0, 50.0) = 20.0;
uniform float animation_speed : hint_range(0.0, 1.0) = 0.05;

vec2 hash2(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453) ;
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
            point = 0.5 + 0.5 * sin(TIME * animation_speed + 6.2831 * point);
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
    
    return second_min - min_dist;  // edge detection between cells
}

void sky() {
    vec3 dir = EYEDIR;
    vec2 uv = vec2(atan(dir.z, dir.x), acos(dir.y)) * cell_scale;
    
    float edge = voronoi(uv);
    float facet_mask = smoothstep(0.0, 1.0 / edge_sharpness, edge);
    
    vec2 cell_id = hash2(floor(uv));
    vec3 facet_color = mix(crystal_color_a, crystal_color_b, cell_id.x);
    
    vec3 final_color = mix(facet_color, bg_color, facet_mask);
    
    float horizon_fade = smoothstep(-0.3, 0.3, dir.y);
    final_color *= mix(0.3, 1.0, horizon_fade);
    
    COLOR = final_color;
}