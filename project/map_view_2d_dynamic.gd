class_name MapView2DDynamic
extends MapView2DLayer
## Handles displaying the "dynamic" [MapView2D] elements.
## This is anything that updates fairly frequently (like selection)
## so that the majority of the map does not need to redraw constantly.


func _draw_vertices() -> void:
	assert(container.map)
	for v in container.map.vertices:
		if not v in container.selection.entities:
			continue

		var c: Color = Color.RED if v in container.selection.entities else Color.WHITE
		draw_map_vertex(v, c)


func _draw_lines() -> void:
	assert(container.map)
	for l in container.map.lines:
		if not l in container.selection.entities:
			continue

		var c: Color = Color.ORANGE if l in container.selection.entities else Color.WHITE
		draw_map_line(l, c)


func _draw_things() -> void:
	assert(container.map)
	for th in container.map.things:
		if not th in container.selection.entities:
			continue

		var c: Color = Color.ORANGE if th in container.selection.entities else Color.WHITE
		draw_map_thing(th, c)


func _draw() -> void:
	if not (container and container.map):
		return

	_draw_lines()
	_draw_vertices()
	_draw_things()
