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


const _CODE_COMMENT := 0x2f
const _CODE_COMMENT_MULTI := 0x2a
const _CODE_NEW_LINE := 0x0a

## Remove C-style comments from a String.
## TODO: Maybe this should be the job of [DoomTextmap].
static func strip_comments(input: String) -> String:
	var ret: String = ""

	var single_comment := false
	var multi_comment := false

	var i := 0
	while (i < input.length()):
		var write_popped := true
		var pop := input.unicode_at(i)
		i += 1

		if pop == _CODE_COMMENT:
			var next := input.unicode_at(i)
			if next == _CODE_COMMENT:
				single_comment = true
				i += 1
			elif next == _CODE_COMMENT_MULTI:
				multi_comment = true
				i += 1
		elif pop == _CODE_NEW_LINE:
			single_comment = false
		elif pop == _CODE_COMMENT_MULTI:
			if multi_comment:
				var next := input.unicode_at(i)
				if next == _CODE_COMMENT:
					multi_comment = false
					write_popped = false
					i += 1 # Skip it

		if (write_popped and not (single_comment or multi_comment)):
			var add := PackedByteArray([pop])
			ret += add.get_string_from_utf8()

	return ret


# Creates a [DoomMap] from a TEXTMAP [String].
static func load_from_text(text: String) -> DoomMap:
	text = strip_comments(text)
	var textmap := DoomTextmap.new(text)
	return DoomMap.new(textmap.data)


# Creates a [DoomMap] from a [WADFile].
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

	# TODO: confirm either utf8 or ascii
	var textmap := textmap_lump.data.get_string_from_utf8()
	var map := DoomMap.load_from_text(textmap)

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
	var ret: String = ""

	ret += "namespace = %s;" % engine_namespace
	for line in lines:
		ret += "\n%s" % str(line)
	for side in sides:
		ret += "\n%s" % str(side)
	for vertex in vertices:
		ret += "\n%s" % str(vertex)
	for sector in sectors:
		ret += "\n%s" % str(sector)
	for thing in things:
		ret += "\n%s" % str(thing)

	return ret


func _init(data: Dictionary) -> void:
	engine_namespace = data.namespace

	for vertex_def: Dictionary in data.vertex:
		vertices.push_back(DoomVertex.new(self, vertex_def))

	for sector_def: Dictionary in data.sector:
		sectors.push_back(DoomSector.new(self, sector_def))

	for side_def: Dictionary in data.sidedef:
		sides.push_back(DoomSidedef.new(self, side_def))

	for line_def: Dictionary in data.linedef:
		lines.push_back(DoomLinedef.new(self, line_def))

	for thing_def: Dictionary in data.thing:
		things.push_back(DoomThing.new(self, thing_def))
