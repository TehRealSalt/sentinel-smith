class_name MapView2DDynamic
extends MapView2DLayer
## Handles displaying the "dynamic" [MapView2D] elements.
## This is anything that updates fairly frequently (like selection)
## so that the majority of the map does not need to redraw constantly.


func _draw_vertices(whitelist: Dictionary[DoomEntity, bool]) -> void:
	assert(container.map)
	for v in container.map.vertices:
		if not whitelist.get(v, false):
			continue

		var c: Color = Color.RED if v in container.selection.entities else Color.WHITE
		draw_map_vertex(v, c)


func _draw_lines(whitelist: Dictionary[DoomEntity, bool]) -> void:
	assert(container.map)
	for l in container.map.lines:
		if not whitelist.get(l, false):
			continue

		var c: Color = Color.ORANGE if l in container.selection.entities else Color.WHITE
		draw_map_line(l, c)


func _draw_sectors(whitelist: Dictionary[DoomEntity, bool]) -> void:
	assert(container.map)
	for s in container.map.sectors:
		if not whitelist.get(s, false):
			continue

		var c: Color = Color.ORANGE if s in container.selection.entities else Color.DIM_GRAY
		draw_map_sector(s, c)


func _draw_things(whitelist: Dictionary[DoomEntity, bool]) -> void:
	assert(container.map)
	for th in container.map.things:
		if not whitelist.get(th, false):
			continue

		var c: Color = Color.ORANGE if th in container.selection.entities else Color.WHITE
		draw_map_thing(th, c)


func _draw() -> void:
	if not (container and container.map):
		return

	var whitelist: Dictionary[DoomEntity, bool] = {}
	for ent: DoomEntity in container.selection.entities:
		var handles: Array[DoomDragHandle] = ent.get_drag_handles()
		for handle: DoomDragHandle in handles:
			whitelist[handle] = true
			for dep: DoomEntity in handle.get_dependants():
				whitelist[dep] = true

	if not whitelist.is_empty():
		_draw_sectors(whitelist)
		_draw_lines(whitelist)
		_draw_vertices(whitelist)
		_draw_things(whitelist)

	if view and view.marquee_active:
		var rect := Rect2(view.marquee_start, view.marquee_end - view.marquee_start).abs()
		draw_rect(rect, Color.ORANGE, false)
		var center_col: Color = Color.ORANGE
		center_col.a = 0.2
		draw_rect(rect, center_col, true)
