shader_type spatial;
render_mode unshaded, cull_disabled, depth_test_disabled, depth_draw_never, blend_add;

uniform sampler2D albedo_texture : source_color, filter_nearest;
uniform vec3 highlight_color : source_color = vec3(0.2, 0.6, 1.0);
uniform float highlight_strength : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 tex = texture(albedo_texture, UV);
    ALBEDO = highlight_color;
    ALPHA = tex.a * highlight_strength;
}