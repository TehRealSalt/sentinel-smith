class_name MapView2DStatic
extends MapView2DLayer
## Handles displaying the "static" [MapView2D] elements.
## This is the vast majority of the map itself.
## This layer is intended to be only updated when
## it is considered absolutely necessary, to avoid needing
## to draw too much at once.


func _draw_vertices() -> void:
	assert(container.map)
	for v in container.map.vertices:
		draw_map_vertex(v)


func _draw_lines() -> void:
	assert(container.map)
	for l in container.map.lines:
		draw_map_line(l)


func _draw_things() -> void:
	assert(container.map)
	for th in container.map.things:
		draw_map_thing(th)


func _draw() -> void:
	if not (container and container.map):
		return

	_draw_lines()
	_draw_vertices()
	_draw_things()
