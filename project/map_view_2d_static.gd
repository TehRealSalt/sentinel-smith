class_name MapView2DStatic
extends MapView2DLayer
## Handles displaying the "static" [MapView2D] elements.
## This is the vast majority of the map itself.
## This layer is intended to be only updated when
## it is considered absolutely necessary, to avoid needing
## to draw too much at once.


func _draw_vertices(blacklist: Dictionary[DoomEntity, bool]) -> void:
	assert(container.map)
	for v in container.map.vertices:
		var blacklisted: bool = blacklist.get(v, false)
		draw_map_vertex(v, Color.WHITE, blacklisted)


func _draw_lines(blacklist: Dictionary[DoomEntity, bool]) -> void:
	assert(container.map)
	for l in container.map.lines:
		var blacklisted: bool = blacklist.get(l, false)
		draw_map_line(l, Color.WHITE, blacklisted)


func _draw_sectors(blacklist: Dictionary[DoomEntity, bool]) -> void:
	assert(container.map)
	for s in container.map.sectors:
		if blacklist.get(s, false):
			continue
		draw_map_sector(s, Color.DIM_GRAY)


func _draw_things(blacklist: Dictionary[DoomEntity, bool]) -> void:
	assert(container.map)
	for th in container.map.things:
		var blacklisted: bool = blacklist.get(th, false)
		draw_map_thing(th, Color.WHITE, blacklisted)


func _draw() -> void:
	if not (container and container.map):
		return

	var blacklist: Dictionary[DoomEntity, bool] = {}
	for ent: DoomEntity in container.selection.entities:
		var handles: Array[DoomDragHandle] = ent.get_drag_handles()
		for handle: DoomDragHandle in handles:
			blacklist[handle] = true
			for dep: DoomEntity in handle.get_dependants():
				blacklist[dep] = true

	_draw_sectors(blacklist)
	_draw_lines(blacklist)
	_draw_vertices(blacklist)
	_draw_things(blacklist)
