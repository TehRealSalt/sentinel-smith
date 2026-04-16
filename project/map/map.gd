class_name DoomMap
extends RefCounted

## This map's name, as specified by the empty header lump.
var map_name: String = ""


## Any extra lumps to save with the map.
var extra_lumps: Array[WADFile.Lump] = []


## This map format's namespace.
var engine_namespace: StringName = &"doom"


## Map format version. For Ring Racers' UDMF,
## should remain 0 for other ports.
var format_version: int = 0


## The list of [DoomVertex] associated with this map.
var vertices: Array[DoomVertex] = []


## The list of [DoomSector] associated with this map.
var sectors: Array[DoomSector] = []


## The list of [DoomSidedef] associated with this map.
var sides: Array[DoomSidedef] = []


## The list of [DoomLinedef] associated with this map.
var lines: Array[DoomLinedef] = []


## The list of [DoomThing] associated with this map.
var things: Array[DoomThing] = []


## A look-up table for every kind of [DoomEntity] [Script],
## to its corresponding [Array].
var entity_type_to_array: Dictionary[Script, Array] = {
	DoomVertex: vertices,
	DoomSector: sectors,
	DoomSidedef: sides,
	DoomLinedef: lines,
	DoomThing: things,
}


## Gets a reference to a [DoomEntity] from its index.
func get_entity_pointer(type: Script, index: int) -> DoomEntity:
	return entity_type_to_array[type].get(index)


## Find a single [DoomVertex] that is closest to the center of a circle.
## [param radius_sqr] is the [i]squared[/i] distance of the circle's radius.
func pick_vertex(world_pos: Vector2, radius_sqr: float) -> DoomVertex:
	var best: DoomVertex = null
	var best_dist: float = INF

	for vertex: DoomVertex in vertices:
		var dist: float = vertex.position.distance_squared_to(world_pos)
		if dist < radius_sqr and dist < best_dist:
			best = vertex
			best_dist = dist

	return best


## Find a single [DoomLinedef] that is closest to the center of a circle.
## [param radius_sqr] is the [i]squared[/i] distance of the circle's radius.
func pick_line(world_pos: Vector2, radius_sqr: float) -> DoomLinedef:
	var best: DoomLinedef = null
	var best_dist: float = INF

	for line: DoomLinedef in lines:
		var p: Vector2 = Geometry2D.get_closest_point_to_segment(world_pos, line.v1.position, line.v2.position)
		var dist: float = p.distance_squared_to(world_pos)
		if dist < radius_sqr and dist < best_dist:
			best = line
			best_dist = dist

	return best


## Find a single [DoomThing] that is closest to the center of a circle.
## [param radius_sqr] is the [i]squared[/i] distance of the circle's radius.
func pick_thing(world_pos: Vector2, radius_sqr: float) -> DoomThing:
	var best: DoomThing = null
	var best_dist: float = INF

	for thing: DoomThing in things:
		var dist: float = thing.position.distance_squared_to(world_pos)
		if dist < radius_sqr and dist < best_dist:
			best = thing
			best_dist = dist

	return best


## Find a single [DoomEntity] that is closest to the center of a circle.
## [param radius_sqr] is the [i]squared[/i] distance of the circle's radius.
## Priority is [DoomVertex] first, [DoomLinedef], then [DoomThing].
func pick_entity(world_pos: Vector2, radius_sqr: float) -> DoomEntity:
	var vertex := pick_vertex(world_pos, radius_sqr)
	if vertex:
		return vertex

	var line := pick_line(world_pos, radius_sqr)
	if line:
		return line

	var thing := pick_thing(world_pos, radius_sqr)
	if thing:
		return thing

	return null


## Gets every single [DoomVertex] within the given [Rect2].
func pick_vertices_in_rect(world_rect: Rect2) -> Array[DoomVertex]:
	var ret: Array[DoomVertex] = []
	for vertex: DoomVertex in vertices:
		if world_rect.has_point(vertex.position):
			ret.push_back(vertex)
	return ret


## Gets every single [DoomLinedef] within the given [Rect2].
func pick_lines_in_rect(world_rect: Rect2) -> Array[DoomLinedef]:
	var ret: Array[DoomLinedef] = []
	for line: DoomLinedef in lines:
		# TODO: would a "fuzzier" select feel better?
		if world_rect.has_point(line.v1.position) and world_rect.has_point(line.v2.position):
			ret.push_back(line)
	return ret


## Gets every single [DoomThing] within the given [Rect2].
func pick_things_in_rect(world_rect: Rect2) -> Array[DoomThing]:
	var ret: Array[DoomThing] = []
	for thing: DoomThing in things:
		if world_rect.has_point(thing.position):
			ret.push_back(thing)
	return ret


## Gets every single [DoomEntity] within the given [Rect2].
func pick_entities_in_rect(world_rect: Rect2) -> Array[DoomEntity]:
	var entities: Array[DoomEntity] = []
	entities.append_array(pick_vertices_in_rect(world_rect))
	entities.append_array(pick_lines_in_rect(world_rect))
	entities.append_array(pick_things_in_rect(world_rect))
	return entities


## Creates a [DoomMap] from a TEXTMAP [String].
static func load_from_text(text: String) -> DoomMap:
	var textmap := DoomTextmap.new(text)
	if textmap.data.is_empty():
		return null
	return DoomMap.new(textmap.data)


## Creates a [DoomMap] from a [WADFile].
static func load_from_wad(wad: WADFile) -> DoomMap:
	assert(wad != null)

	# TODO: WADs can contain more than 1 map.
	# For now it's easier to support single-map WADs,
	# since you need to do this for PK3 anyways.
	var header_lump := wad.lumps[0]

	var textmap_lump := wad.lumps[1]
	if textmap_lump.name != "TEXTMAP":
		push_warning("This WAD is not a UDMF file")
		return null

	# TODO: Is this UTF8 or ASCII?
	var textmap := textmap_lump.data.get_string_from_ascii()
	var map := DoomMap.load_from_text(textmap)
	if map == null:
		push_warning("Failed to load map from WAD")
		return null

	var found_end := false
	for lump: WADFile.Lump in wad.lumps.slice(2):
		if lump.name == "ENDMAP":
			found_end = true
			break

		map.extra_lumps.push_back(lump)
		print("Found extra map lump '%s'" % lump.name)

	if found_end == false:
		push_error("Found TEXTMAP, but not ENDMAP")
		return null

	map.map_name = header_lump.name
	print("Loaded map '%s'" % map.map_name)

	return map


func _to_string() -> String:
	var ret: PackedStringArray = []

	ret.push_back("namespace = %s;" % engine_namespace)
	for line in lines:
		ret.push_back(str(line))
	for side in sides:
		ret.push_back(str(side))
	for vertex in vertices:
		ret.push_back(str(vertex))
	for sector in sectors:
		ret.push_back(str(sector))
	for thing in things:
		ret.push_back(str(thing))

	return '\n'.join(ret)


func _init(data: Dictionary) -> void:
	engine_namespace = data.namespace

	PerfTiming.start(&'DoomMap.vertices')
	for vertex_def: Dictionary in data.vertex:
		vertices.push_back(DoomVertex.new(self, vertex_def))
	PerfTiming.stop(&'DoomMap.vertices')

	PerfTiming.start(&'DoomMap.sectors')
	for sector_def: Dictionary in data.sector:
		sectors.push_back(DoomSector.new(self, sector_def))
	PerfTiming.stop(&'DoomMap.sectors')

	PerfTiming.start(&'DoomMap.sides')
	for side_def: Dictionary in data.sidedef:
		sides.push_back(DoomSidedef.new(self, side_def))
	PerfTiming.stop(&'DoomMap.sides')

	PerfTiming.start(&'DoomMap.lines')
	for line_def: Dictionary in data.linedef:
		lines.push_back(DoomLinedef.new(self, line_def))
	PerfTiming.stop(&'DoomMap.lines')

	PerfTiming.start(&'DoomMap.things')
	for thing_def: Dictionary in data.thing:
		things.push_back(DoomThing.new(self, thing_def))
	PerfTiming.stop(&'DoomMap.things')
