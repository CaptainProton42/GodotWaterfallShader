shader_type spatial;

render_mode specular_toon, world_vertex_coords;

const float PI = 3.1415926535;

uniform sampler2D noise_tex;
uniform sampler2D palette;
uniform vec2 point_a;
uniform vec2 point_b;

varying mat4 CAMERA;
varying vec3 VERTEX_VIEW_POS;

void vertex() {
	CAMERA = CAMERA_MATRIX;
	VERTEX_VIEW_POS = (INV_CAMERA_MATRIX*vec4(VERTEX, 1.0f)).xyz;
}

/* Signed distance field of a line segment.
   https://www.iquilezles.org/www/articles/distfunctions2d/distfunctions2d.htm */
float sdSegment(vec2 p, vec2 a, vec2 b )
{
    vec2 pa = p-a, ba = b-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h );
}

void fragment() {
	/* Use the distance to a line segment that represents the waterfall. */
	float r = sdSegment(UV, point_a, point_b);
	
	/* Use angular coordinate around point in the center of the waterfall
	   as an approximation. */
	float phi = mod(atan((UV - 0.5f*(point_a+ point_b)).x, (UV -  0.5f*(point_a+ point_b)).y) - 0.5f * PI, 2.0f * PI);
	
	/* Sample noise from these coordinates with some scaling factors.
	   This is a bit messy and has a seam but I hide it behind the waterfall ;-) */
	ALBEDO.r = 1.0f * (1.0f - 0.5f * (texture(noise_tex, vec2(5.0f*r - 0.4f*TIME, phi / 6.0f / PI)).r + texture(noise_tex, 2.0f*vec2(4.32f*r - 0.6f*TIME, phi / 6.0f / PI)).g));
	ALBEDO.r += 0.5f*smoothstep(0.5f, 0.0f, r) - 0.25f;
	
	/* Retrieve the depth buffer to create shorelines. */
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	vec4 world = CAMERA * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	vec3 world_position = world.xyz / world.w;
	
	float water_dist = (linear_depth + VERTEX_VIEW_POS).z;
	ALBEDO.r += smoothstep(0.1f, 0.0f, water_dist);
	
	/* Apply color map. */
	ALBEDO = texture(palette, vec2(ALBEDO.r, 0.5f)).rgb;
}