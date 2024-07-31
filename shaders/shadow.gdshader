shader_type canvas_item;
//render_mode light_only;

uniform sampler2D u_dither_tex: filter_nearest, repeat_enable; // 16x16 dither texture

// https://godotshaders.com/shader/2d-outline-inline/

uniform vec4 color : source_color = vec4(1.0);
uniform float width : hint_range(0, 10) = 1.0;
uniform int pattern : hint_range(0, 2) = 0; // diamond, circle, square
uniform bool inside = false;
uniform bool add_margins = true; // only useful when inside is false

uniform bool do_outline = false;

void vertex() {
	if (do_outline) {
		if (add_margins) {
			VERTEX += (UV * 2.0 - 1.0) * width;
		}
	}
}

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, sampler2D texture) {
	for (float i = -ceil(width); i <= ceil(width); i++) {
		float x = abs(i) > width ? width * sign(i) : i;
		float offset;
		
		if (pattern == 0) {
			offset = width - abs(x);
		} else if (pattern == 1) {
			offset = floor(sqrt(pow(width + 0.5, 2) - x * x));
		} else if (pattern == 2) {
			offset = width;
		}
		
		for (float j = -ceil(offset); j <= ceil(offset); j++) {
			float y = abs(j) > offset ? offset * sign(j) : j;
			vec2 xy = uv + texture_pixel_size * vec2(x, y);
			
			if ((xy != clamp(xy, vec2(0.0), vec2(1.0)) || texture(texture, xy).a <= 0.0) == inside) {
				return true;
			}
		}
	}
	
	return false;
}

void fragment() {
	vec2 uv = UV;
	
	if (add_margins) {
		vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(width * 2.0));
		
		uv = (uv - texture_pixel_size * width) * TEXTURE_PIXEL_SIZE / texture_pixel_size;
		
		if (uv != clamp(uv, vec2(0.0), vec2(1.0))) {
			COLOR.a = 0.0;
		} else {
			COLOR = texture(TEXTURE, uv);
		}
	} else {
		COLOR = texture(TEXTURE, uv);
	}
	
	if (do_outline) {
		if ((COLOR.a > 0.0) == inside && hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, TEXTURE)) {
			COLOR.rgb = inside ? mix(COLOR.rgb, color.rgb, color.a) : color.rgb;
			COLOR.a += (1.0 - COLOR.a) * color.a;
		}
	}
	else {
		COLOR = texture(TEXTURE, UV);
	}
}

void light() {
	if (LIGHT_COLOR.a > 0.0) { // not shading on transparent pixels in the shadow tex
		//vec2 altered_texture_size = vec2(textureSize(TEXTURE, 0)) / float(1);
		vec2 texture_size = vec2(textureSize(TEXTURE, 0));
		ivec2 noise_size = textureSize(u_dither_tex, 0);
		vec2 inv_noise_size = vec2(1.0 / float(noise_size.x), 1.0 / float(noise_size.y));
		vec2 noise_uv = UV * inv_noise_size * vec2(float(texture_size.x), float(texture_size.y));
		vec4 dither_col = texture(u_dither_tex, noise_uv);
		
		//LIGHT = vec4(0.84, 0.48, 0.74, dither_col.a);
		//LIGHT = vec4(UV.x, UV.y, 0.0, 1.0);
		LIGHT = dither_col;
	}
}
