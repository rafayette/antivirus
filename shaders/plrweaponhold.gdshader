shader_type canvas_item;

uniform int pixel_size : hint_range(1, 64) = 8;
uniform int color_levels : hint_range(2, 16) = 4;
uniform vec3 hot_color : source_color = vec3(1.0, 0.15, 0.15);
uniform float heat_shift : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    // Pixelation: snap UV coordinates to a grid based on the texture's actual pixel size
    vec2 texture_size = vec2(textureSize(TEXTURE, 0));
    vec2 grid_size = texture_size / float(pixel_size);
    vec2 pixelated_uv = floor(UV * grid_size) / grid_size;

    vec4 tex_color = texture(TEXTURE, pixelated_uv);
	
	float intensity = max(tex_color.r, max(tex_color.g, tex_color.b));
    vec3 target_color = hot_color * intensity;
    vec3 final_color = mix(tex_color.rgb, target_color, heat_shift);

    // Posterization: quantize each color channel to a fixed number of levels
    vec3 posterized = floor(final_color.rgb * float(color_levels)) / float(color_levels);

    COLOR = vec4(posterized, tex_color.a);
}