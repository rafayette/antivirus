shader_type canvas_item;

void fragment() {
    // UV.x ranges from 0.0 (left) to 1.0 (right)
    // We use it directly for alpha: 1.0 = opaque, 0.0 = transparent
    //COLOR = vec4(texture(TEXTURE, UV).rgb, UV.x);
    
    // If using a solid color without a texture, use:
    COLOR = vec4(vec3(1.0), UV.x); // White with horizontal alpha fade
}