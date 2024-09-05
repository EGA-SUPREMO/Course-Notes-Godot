shader_type canvas_item;
render_mode blend_sub;

float getAlpha(float col, float alpha) {
	return col + (1.0 - col) * alpha;
}

void fragment() {
	/*vec4 original_colour = texture(TEXTURE, UV).rgba;
	vec4 destruction_map_colour = texture(destruction_mask, UV).rgba;

	COLOR = vec4(original_colour.r, original_colour.g, original_colour.b, original_colour.a * destruction_map_colour.a);*/
	vec3 tex = texture(TEXTURE, UV).rgb;
	float alpha = 1.0 - COLOR.a;
	
	COLOR.rgb = vec3(
		getAlpha(tex.r, alpha),
		getAlpha(tex.g, alpha),
		getAlpha(tex.b, alpha)
	);
	COLOR.rgba = vec4(texture(TEXTURE, UV).rgb, 0.0);
}