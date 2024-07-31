shader_type canvas_item;

const int bayer_n = 4;
const mat4 bayer_matrix = mat4(	vec4(-0.5, 0.0, -0.375, 0.125), 
								vec4(0.25, -0.25, 0.375, -0.125), 
								vec4(-0.3125, 0.1875, -0.4375, 0.0625), 
								vec4(0.4375, -0.0625, 0.3125, -0.1875)	);

uniform float bayer_r = 2.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	//float bayer_matrix_4x4[4][bayer_n] = {
		//{-0.5, 0.0, -0.375, 0.125},
		//{0.25, -0.25, 0.375, -0.125},
		//{-0.3125, 0.1875, -0.4375, 0.0625},
		//{0.4375, -0.0625, 0.3125, -0.1875}
	//};
	
	// COLUMN ROW
	vec4 original_color = texture(TEXTURE, UV);
	ivec2 nearest_pixel_uv = ivec2(TEXTURE_PIXEL_SIZE * UV);
	float bayer_value = bayer_matrix[nearest_pixel_uv.y % bayer_n][nearest_pixel_uv.x % bayer_n];
	vec4 output_color = original_color + (bayer_r * bayer_value);
	
	if (output_color.x < 0.5) {
		COLOR.a = 1.0;
	}
	else {
		COLOR.a = 0.0;
	}
	
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
