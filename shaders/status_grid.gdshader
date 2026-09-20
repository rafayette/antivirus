shader_type canvas_item;

uniform vec3 hot_color : source_color = vec3(1.0, 0.15, 0.15);
uniform float heat_shift : hint_range(0.0, 1.0) = 0.0;
uniform vec2 scroll_speed = vec2(0.05, 0.0);

void fragment() {
    vec2 scrolled_uv = UV + scroll_speed * TIME;
    vec4 tex = texture(TEXTURE, scrolled_uv);
    
    float intensity = max(tex.r, max(tex.g, tex.b));
    vec3 target_color = hot_color * intensity;
    vec3 final_color = mix(tex.rgb, target_color, heat_shift);
    
    COLOR = vec4(final_color, tex.a);
}