shader_type spatial;
render_mode unshaded, cull_disabled, blend_add, depth_draw_never;

uniform vec3 pulse_origin;
uniform float wave_radius : hint_range(0.0, 100.0) = 0.0;
uniform float band_width : hint_range(0.1, 5.0) = 1.0;
uniform vec3 pulse_color : source_color = vec3(0.2, 0.6, 1.0);
uniform float alpha_fade : hint_range(0.0, 1.0) = 1.0;

varying vec3 world_pos;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    float dist = distance(world_pos.xz, pulse_origin.xz);
    float ring = 1.0 - smoothstep(0.0, band_width, abs(dist - wave_radius));
    ALBEDO = pulse_color;
    ALPHA = ring * alpha_fade;
}