shader_type spatial;

render_mode world_vertex_coords, specular_toon;

uniform sampler2D noise_tex;
uniform sampler2D palette;
uniform float palette_offset : hint_range(0.0f, 1.0f);
varying vec3 VERTEX_VAR;
varying vec3 NORMAL_VAR;

vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
	vec4 samp=vec4(0.0);
	samp+= texture(p_sampler,p_triplanar_pos.xy) * p_weights.z;
	samp+= texture(p_sampler,p_triplanar_pos.xz) * p_weights.y;
	samp+= texture(p_sampler,p_triplanar_pos.zy * vec2(-1.0,1.0)) * p_weights.x;
	return samp;
}


void vertex() {
	VERTEX_VAR = VERTEX;
	NORMAL_VAR = NORMAL;
}

void fragment() {
	vec3 noise = texture(noise_tex, vec2(VERTEX_VAR.y, 0.5f)).rgb;
	
	float value = noise.r;
	value -= smoothstep(0.9f, 0.95f, NORMAL_VAR.y);
	value = mod(value + palette_offset, 1.0f);
	
	ALBEDO = texture(palette, vec2(value, 0.5f)).rgb;
}