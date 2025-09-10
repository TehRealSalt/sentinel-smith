class_name DoomMap
extends Node

## This map's name, as specified by the empty header lump.
var map_name: String = ""

## Any extra lumps to save with the map.
var extra_lumps: Array[WADFile.Lump] = []

## This map format's namespace.
var engine_namespace: StringName = &"Doom"


static func load_from_text(textmap: String) -> DoomMap:
	var map := DoomMap.new()
	print("TODO: load textmap")
	return map


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
