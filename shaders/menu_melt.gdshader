shader_type canvas_item;

uniform float melt_progress : hint_range(0.0, 1.0) = 0.0;
uniform float column_count : hint_range(20.0, 400.0) = 120.0;
uniform float randomness : hint_range(0.0, 1.0) = 0.4;

float hash(float n) {
    return fract(sin(n * 127.1) * 43758.5453);
}

void fragment() {
    float column = floor(UV.x * column_count);
    float column_offset = hash(column) * randomness;
    
    // each column starts melting at a slightly different point in the progress
    float local_progress = clamp((melt_progress - column_offset) / (1.0 - randomness), 0.0, 1.0);
    
    // shift this column's sampled UV upward as it "melts down" (revealing what's below)
    vec2 sample_uv = UV;
    sample_uv.y -= local_progress * 1.3;  // 1.3 so it fully clears the screen
    
    if (sample_uv.y > 1.0 || sample_uv.y < 0.0) {
        discard;  // fully melted away in this column, nothing left to show
    }
    
    vec4 tex_color = texture(TEXTURE, sample_uv);
    COLOR = tex_color;
}