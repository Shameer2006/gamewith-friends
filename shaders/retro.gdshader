shader_type spatial;
// Note the 'd' at the end of depth_test_disabled
render_mode unshaded, shadows_disabled, depth_test_disabled, depth_draw_never;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform int color_depth : hint_range(1, 8) = 5;
uniform bool dithering = true;
uniform int resolution_scale = 4;

int dithering_pattern(ivec2 fragcoord) {
    const int pattern[16] = {
        -4, +0, -3, +1, 
        +2, -2, +3, -1, 
        -3, +1, -4, +0, 
        +3, -1, +2, -2
    };
    
    int x = fragcoord.x % 4;
    int y = fragcoord.y % 4;
    
    return pattern[y * 4 + x];
}

void vertex() {
    POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
    // Calculate pixelated UVs
    vec2 screen_size = vec2(textureSize(screen_texture, 0));
    vec2 pixel_uv = floor(SCREEN_UV * screen_size / float(resolution_scale)) * float(resolution_scale) / screen_size;
    
    // Read from the declared screen_texture
    vec3 color = texture(screen_texture, pixel_uv).rgb;
    
    ivec3 c = ivec3(round(color * 255.0));
    
    if (dithering) {
        ivec2 uv_int = ivec2(SCREEN_UV * screen_size / float(resolution_scale));
        c += ivec3(dithering_pattern(uv_int));
    }
    
    c >>= (8 - color_depth);
    ALBEDO = vec3(c) / float(1 << color_depth);
}
