shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.25;
uniform float scanline_count : hint_range(100.0, 800.0) = 360.0;
uniform float curvature : hint_range(0.0, 0.3) = 0.08;
uniform float vignette_strength : hint_range(0.0, 2.0) = 0.8;
uniform float chromatic_aberration : hint_range(0.0, 0.01) = 0.002;
uniform float flicker_speed : hint_range(0.0, 20.0) = 6.0;
uniform float flicker_intensity : hint_range(0.0, 0.2) = 0.03;

vec2 curve_uv(vec2 uv) {
    uv = uv * 2.0 - 1.0;
    vec2 offset = abs(uv.yx) / vec2(1.0 / curvature, 1.0 / curvature);
    uv = uv + uv * offset * offset;
    uv = uv * 0.5 + 0.5;
    return uv;
}

void fragment() {
    vec2 uv = curve_uv(SCREEN_UV);

    float r = texture(screen_tex, uv + vec2(chromatic_aberration, 0.0)).r;
    float g = texture(screen_tex, uv).g;
    float b = texture(screen_tex, uv - vec2(chromatic_aberration, 0.0)).b;
    vec3 color = vec3(r, g, b);

    float scanline = sin(uv.y * scanline_count * PI) * 0.5 + 0.5;
    color *= mix(1.0, scanline, scanline_intensity);

    vec2 centered = uv - 0.5;
    float vignette = 1.0 - dot(centered, centered) * vignette_strength;
    color *= vignette;

    float flicker = 1.0 - flicker_intensity + flicker_intensity * sin(TIME * flicker_speed);
    color *= flicker;

	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
    }
	
	else {
		COLOR = vec4(color, 1.0);
	}
}