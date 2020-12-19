shader_type spatial;

render_mode specular_toon;

uniform sampler2D world_pos;
uniform sampler2D noise_tex;
uniform sampler2D palette;

uniform bool view_cmap_value = false;
uniform float noise_amplitude : hint_range(0.0f, 0.1f);
uniform vec2 noise_scale = vec2(0.1f, 1.0f);
uniform float water_speed : hint_range(0.0f, 10.0f);
uniform float rim_thickness : hint_range(0.0f, 1.0f);
uniform float noise_multiplicator : hint_range(0.0f, 1.0f);
uniform float spray_distance : hint_range(0.0f, 1.0f);
uniform float streak_width : hint_range(0.0f, 1.0f);

varying vec3 vertex_pos;

void vertex() {
	/* Sample some Worley noise. */
	vec3 noise = texture(noise_tex, (UV + vec2(water_speed * TIME, 0.0f)) *  noise_scale).rgb;
	VERTEX.x += (noise_amplitude * (noise.r - 0.5f) ) * smoothstep(0.95f, 0.8f, VERTEX.y);
	vertex_pos = VERTEX;
}

void fragment() {
	/* Sample some worley noise. */
	vec3 noise = texture(noise_tex, (UV + vec2(water_speed * TIME, 0.0f)) * noise_scale).rgb;
	
	/* Get UVs from top-down view as model coordinates in the horizontal plane
	   and add some noise. */
	vec2 top_down_uv = vertex_pos.xz + noise_amplitude * (noise.rg - 0.5f);
	
	/* Get height of objects in the waterfall and discard all fragments below it. */
	float h = texture(world_pos, top_down_uv).y;
	if (vertex_pos.y < h) discard;
	
	/* First, get some noise. Then, add effects like the waterfall rims, foam streaks
	   from objects and spray at the bottom of the waterfall. value the resulting value
	   to a color palette. 
	   Check "View Cmap Value" in the shader params to see the raw value before color valueping. */
	float value = noise_multiplicator * noise.r;
	value += smoothstep(rim_thickness, 0.0f, UV.y) + smoothstep(1.0f-rim_thickness, 1.0f, UV.y);
	value += smoothstep(spray_distance, 0.0f, vertex_pos.y);
	
	/* Apply a simple blur filter to the object height to create foam streaks
	   next to objects. */
	float blur_h = max(h, texture(world_pos, top_down_uv + vec2(0.0f, streak_width)).y);
	blur_h = max(blur_h, texture(world_pos, top_down_uv - vec2(0.0f, streak_width)).y);
	value += smoothstep(vertex_pos.y - 0.05f, vertex_pos.y, blur_h);
	
	/* Clamp value to [0.0, 1.0] before valueping to color. */
	value = clamp(value, 0.0f, 1.0f);
	
	/* value color palette to value. */
	ALBEDO = texture(palette, vec2(value, 0.5f)).rgb;
	
	/* Debug: Render value without color value applied. */
	if (view_cmap_value) {
		ALBEDO = vec3(value, 0.0f, 0.0f);
	}
	
	/* Fade out on top of cliffs for artistic purposes. */
	ALPHA = smoothstep(1.0f, 0.9f, UV.x);
}