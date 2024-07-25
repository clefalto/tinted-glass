shader_type canvas_item;
//render_mode light_only;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
}

void light() {
	if (COLOR.a > 0.0) {
		LIGHT = vec4(0.84, 0.48, 0.74, LIGHT_COLOR.a);
	}
}
