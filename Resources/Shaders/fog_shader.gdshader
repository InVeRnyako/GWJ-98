shader_type canvas_item;

uniform sampler2D overlay_texture : source_color , repeat_enable , filter_nearest;
uniform float scroll_speed = -0.05;

void fragment() {
    vec4 tile_color = texture(TEXTURE, UV);
    
    if (tile_color.a > 0.0) {
        vec2 scroll_uv = SCREEN_UV + vec2(TIME * scroll_speed, 0.0);
        vec4 overlay_color = texture(overlay_texture, scroll_uv);
        COLOR = vec4(overlay_color.rgb, tile_color.a * overlay_color.a);
    } else {
        COLOR = vec4(0.0);
    }
}