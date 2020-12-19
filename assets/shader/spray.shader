shader_type spatial;

render_mode unshaded, world_vertex_coords;

uniform vec4 color : hint_color;
uniform float noise_amplitude : hint_range(0.0f, 0.1f);
uniform float noise_scale : hint_range(0.0f, 1.0f);
uniform float timescale : hint_range(0.0f, 1.0f);
uniform sampler2D noise_tex;

void vertex() {
	VERTEX += noise_amplitude*(texture(noise_tex, noise_scale * VERTEX.xz + timescale * TIME).rgb - 0.5f);
}

void fragment() {
	ALBEDO = color.rgb;
}