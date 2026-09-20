shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque, blend_mix;

uniform sampler2D albedo_texture : source_color;
uniform float dissolve_progress : hint_range(0.0, 1.0) = 0.0;
uniform vec3 outline_color : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 scanline_color : source_color = vec3(0.2, 0.6, 1.0);
uniform float scanline_width : hint_range(0.001, 0.05) = 0.01;
uniform float outline_thickness : hint_range(0.0, 0.01) = 0.003;

void fragment() {
    vec4 tex_color = texture(albedo_texture, UV);
    float dist_from_center = abs(UV.y - 0.5);
    
    bool dissolving = dissolve_progress > 0.0;
    
    if (dissolving && dist_from_center < dissolve_progress) {
        discard;
    }
    
    vec3 final_color = tex_color.rgb;
    float final_alpha = tex_color.a;
    
    if (dissolving) {
        float alpha_up = texture(albedo_texture, UV + vec2(0.0, outline_thickness)).a;
        float alpha_down = texture(albedo_texture, UV - vec2(0.0, outline_thickness)).a;
        float alpha_left = texture(albedo_texture, UV - vec2(outline_thickness, 0.0)).a;
        float alpha_right = texture(albedo_texture, UV + vec2(outline_thickness, 0.0)).a;
        bool is_edge = tex_color.a < 0.1 && (alpha_up + alpha_down + alpha_left + alpha_right) > 0.1;
        
        if (is_edge && dist_from_center > dissolve_progress) {
            final_color = outline_color;
            final_alpha = 1.0;
        }
        
        float scan_dist = abs(dist_from_center - dissolve_progress);
        bool near_sprite_content = tex_color.a > 0.1 || is_edge;
        if (scan_dist < scanline_width && near_sprite_content) {
            final_color = scanline_color;
            final_alpha = 1.0;
        }
    }
    
    ALBEDO = final_color;
    ALPHA = final_alpha;
}