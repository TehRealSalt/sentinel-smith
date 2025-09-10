class_name DoomMap
extends Node

## This map's name, as specified by the empty header lump.
var map_name: String = ""

## Any extra lumps to save with the map.
var extra_lumps: Array[WADFile.Lump] = []

## This map format's namespace.
var engine_namespace: StringName = &"Doom"


const _CODE_COMMENT := 0x2f
const _CODE_COMMENT_MULTI := 0x2a
const _CODE_NEW_LINE := 0x0a

## Remove C-style comments from a String.
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


const _SYNTAX_INT := '[+-]?[1-9]+[0-9]*|0[0-9]+|0x[0-9A-Fa-f]+'
const _SYNTAX_FLOAT := '[+-]?[0-9]+[.0-9]*([eE][+-]?[0-9]+)?'
const _SYNTAX_STR := '"([^"\\]*(\\.[^"\\]*)*)"'
const _SYNTAX_KEYWORD := '[^{}();"\'\n\t ]+'

const _SYNTAX_IDENTIFIER := '[A-Za-z_]+[A-Za-z0-9_]*'

static func _combined_syntax(inputs: PackedStringArray) -> String:
	return ("(" + (")|(".join(inputs)) + ")")

var exp_int := RegEx.create_from_string(_SYNTAX_INT)
var exp_float := RegEx.create_from_string(_SYNTAX_FLOAT)
var exp_str := RegEx.create_from_string(_SYNTAX_STR)
var exp_keyword := RegEx.create_from_string(_SYNTAX_KEYWORD)
var exp_value := RegEx.create_from_string(_combined_syntax([_SYNTAX_INT, _SYNTAX_FLOAT, _SYNTAX_STR, _SYNTAX_KEYWORD]))
var exp_identifier := RegEx.create_from_string(_SYNTAX_IDENTIFIER)
var exp_equals := RegEx.create_from_string("={1}")
var exp_semicolon := RegEx.create_from_string(";{1}")


# Creates a [DoomMap] from a TEXTMAP [String].
static func load_from_text(textmap: String) -> DoomMap:
	textmap = strip_comments(textmap)
	var map := DoomMap.new()
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
