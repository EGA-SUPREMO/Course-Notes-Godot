shader_type canvas_item;

render_mode blend_sub;
// ESTO SE EJECUTA CADA FRAME, PARA REDUCIR LAG, QUE SE EJECUTE UNA VES Y SE GUARDE EN UNA IMAGEN
void fragment() {
	vec4 original_colour = texture(TEXTURE, UV).rgba;
	COLOR = vec4(1.0 - original_colour.r, 1.0 - original_colour.b, 1.0 - original_colour.g, original_colour.a/2.0);
	//COLOR.b = smoothstep(0.5, 0.7, COLOR.b);
}