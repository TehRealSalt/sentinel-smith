shader_type canvas_item;

uniform float grid_size = 32.0;
uniform float major_factor = 8.0;

uniform vec4 minor_color : source_color = vec4(0.35, 0.35, 0.35, 1.0);
uniform vec4 major_color : source_color = vec4(0.55, 0.55, 0.55, 1.0);

void fragment()
{
	vec2 world_pos = UV * TEXTURE_PIXEL_SIZE;
	
	// Compute grid
	vec2 cell = abs(fract(world_pos / grid_size) - 0.5);
	float thickness = 0.02 * grid_size;

	float minor = step(cell.x, thickness) + step(cell.y, thickness);

	float major = 0.0;
	if (major_factor > 1.0)
	{
		vec2 cell_major = abs(fract(world_pos / (grid_size * major_factor)) - 0.5);
		major = step(cell_major.x, thickness * 1.5) + step(cell_major.y, thickness * 1.5);
	}

	float mask = clamp(minor + major, 0.0, 1.0);
	vec4 color = mix(minor_color, major_color, clamp(major, 0.0, 1.0));

	COLOR = color * mask;
}
