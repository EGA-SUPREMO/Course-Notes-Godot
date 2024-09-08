shader_type canvas_item;

render_mode blend_add;

uniform sampler2D destruction_mask: hint_default_transparent;
uniform float ratio;
uniform float radius;

float getAlpha(float col, float alpha) {
	return col + (1.0 - col) * alpha;
}


void fragment() {
	vec4 original_colour = texture(TEXTURE, UV).rgba;
	vec4 destruction_map_colour = texture(destruction_mask, UV).rgba;

	//COLOR = vec4(original_colour.r, original_colour.g, original_colour.b, destruction_map_colour.a - original_colour.a);
	//if (original_colour.a == 1.0) {
    	COLOR = vec4(original_colour.rgb, 0.0); // Set alpha to 0 when both alphas are 1
	//}
	//COLOR = vec4(destruction_map_colour.rbga);

}