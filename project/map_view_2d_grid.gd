class_name MapView2DGrid
extends Control

## The "frequent" grid lines color.
const COLOR_MINOR: Color = Color(0.2, 0.2, 0.2)


## The "infrequent" grid lines color.
const COLOR_MAJOR: Color = Color(0.3, 0.3, 0.3)


## The [MapContainer] that this layer is for.
var container: MapContainer = null


## The transform of the other layers.
## Updates rendering of the grid to be in world space. 
var transform: Transform2D:
	set(v):
		transform = v
		queue_redraw()


func _draw_grid(grid_size: float, color: Color) -> void:
	var inv: Transform2D = transform.affine_inverse()

	var top_left: Vector2 = inv * Vector2.ZERO
	var bottom_right: Vector2 = inv * size

	var world_min: Vector2 = Vector2(
		minf(top_left.x, bottom_right.x),
		minf(top_left.y, bottom_right.y)
	)
	var world_max: Vector2 = Vector2(
		maxf(top_left.x, bottom_right.x),
		maxf(top_left.y, bottom_right.y)
	)

	var start: Vector2 = Vector2(
		ceilf(world_min.x / grid_size) * grid_size,
		ceilf(world_min.y / grid_size) * grid_size
	)

	var end: Vector2 = Vector2(
		floorf(world_max.x / grid_size) * grid_size,
		floorf(world_max.y / grid_size) * grid_size
	)

	for x in range(start.x, end.x + 1, grid_size):
		var v1: Vector2 = (transform * Vector2(x, world_min.y)).floor()
		var v2: Vector2 = (transform * Vector2(x, world_max.y)).floor()
		draw_line(v1, v2, color)

	for y in range(start.y, end.y + 1, grid_size):
		var v1: Vector2 = (transform * Vector2(world_min.x, y)).floor()
		var v2: Vector2 = (transform * Vector2(world_max.x, y)).floor()
		draw_line(v1, v2, color)


func _draw() -> void:
	var zoom: float = transform.get_scale().x

	var minor_size: float = container.grid_size
	while minor_size * zoom < 8.0:
		minor_size *= 2.0

	var major_size: float = container.grid_size * 8.0
	while major_size * zoom < 8.0:
		major_size *= 2.0

	if minor_size != major_size:
		_draw_grid(minor_size, COLOR_MINOR)

	_draw_grid(major_size, COLOR_MAJOR)
