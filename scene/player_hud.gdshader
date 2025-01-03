shader_type canvas_item;

uniform vec3 player_color;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    float outline_thickness = 0.1; // Adjust this for thicker or thinner outlines

    // Transparent pixels are ignored by default
    if (tex_color.a < 0.1) {
        COLOR = vec4(0.0) * COLOR; // Fully transparent
        //return; // <- This will NOT work; removed and fixed below
    } else {

	    // Offsets for neighboring pixel sampling
	    vec2 offsets[8] = vec2[](
	        vec2(-outline_thickness, -outline_thickness), // Top-left
	        vec2(0.0, -outline_thickness),               // Top
	        vec2(outline_thickness, -outline_thickness), // Top-right
	        vec2(-outline_thickness, 0.0),               // Left
	        vec2(outline_thickness, 0.0),                // Right
	        vec2(-outline_thickness, outline_thickness), // Bottom-left
	        vec2(0.0, outline_thickness),                // Bottom
	        vec2(outline_thickness, outline_thickness)   // Bottom-right
	    );

	    // Check neighboring pixels for transparency
	    bool is_edge = false;
	    for (int i = 0; i < 8; i++) {
	        vec2 sample_uv = UV + offsets[i];
	        vec4 neighbor_color = texture(TEXTURE, sample_uv);
	        if (neighbor_color.a < 0.1) {
	            is_edge = true;
	            break;
	        }
	    }

	    // Set the final color
	    if (is_edge) {
	        // If this pixel is at an edge, color it
	        COLOR = vec4(player_color, 1.0);// * COLOR;
	    } else {
	        // Otherwise, keep the original color
	        COLOR = tex_color * COLOR;
	    }
	}
}
