class_name WADFile
extends Resource
## A Doom "Where's All the Data?" file.


## The expected [member identifier] of an internal WAD.
const INTERNAL_ID: String = "IWAD"


## The expected [member identifier] of a patch WAD.
const PATCH_ID: String = "PWAD"


## The identifier of the WAD file.
## Expected to be either [const INTERNAL_ID] or [const PATCH_ID].
var identifier: String = PATCH_ID


## Set to true if this is an internal WAD (aka, an IWAD).
var internal: bool = false


## A single [WADFile] lump.
class Lump:
	## The maximum allowed size for a lump name.
	const NAME_MAX: int = 8


	## The name of this lump.
	var name: String = ""


	## A [PackedByteArray] of this lump's raw data.
	var data: PackedByteArray = []


	func _init(p_name: String, p_data: PackedByteArray) -> void:
		name = p_name
		data = p_data


## All of the data contained within this WAD, ordered.
var lumps: Array[Lump] = []


# Private -- expected offsets & sizes of different elements in the WAD. 
const _HEADER_ID_POS: int = 0x00
const _HEADER_ID_LEN: int = 4
const _HEADER_COUNT_POS: int = 0x04
const _HEADER_DIR_POS: int = 0x08

const _ENTRY_START_OFFSET: int = 0x00
const _ENTRY_SIZE_OFFSET: int = 0x04
const _ENTRY_NAME_OFFSET: int = 0x08
const _ENTRY_LENGTH: int = _ENTRY_NAME_OFFSET + Lump.NAME_MAX

func _read_identifier(bytes: PackedByteArray) -> Error:
	var id_bytes := bytes.slice(_HEADER_ID_POS, _HEADER_ID_POS + _HEADER_ID_LEN)
	var id_size := id_bytes.size()
	if id_size < _HEADER_ID_LEN:
		return ERR_FILE_EOF

	assert(
		id_size == _HEADER_ID_LEN,
		"Name size mismatch (got %d, expected %d)" % [id_size, _HEADER_ID_LEN]
	)

	identifier = id_bytes.get_string_from_ascii()
	internal = (identifier == INTERNAL_ID)

	if (identifier == INTERNAL_ID or identifier == PATCH_ID):
		return OK

	return ERR_FILE_UNRECOGNIZED


func _read_directory(bytes: PackedByteArray) -> Error:
	var num_lumps := bytes.decode_s32(_HEADER_COUNT_POS)
	if num_lumps == 0:
		return ERR_FILE_EOF
	elif num_lumps < 0:
		return ERR_FILE_CORRUPT

	var dir_offset := bytes.decode_s32(_HEADER_DIR_POS)
	if dir_offset == 0:
		return ERR_FILE_EOF
	elif dir_offset < 0:
		return ERR_FILE_CORRUPT

	for i: int in num_lumps:
		var entry_offset := dir_offset + (i * _ENTRY_LENGTH)
		var entry_bytes := bytes.slice(entry_offset, entry_offset + _ENTRY_LENGTH)
		var entry_size := entry_bytes.size()
		if entry_size < _ENTRY_LENGTH:
			return ERR_FILE_EOF

		assert(
			entry_size == _ENTRY_LENGTH,
			"Directory entry size mismatch (got %d, expected %d)" % [entry_size, _ENTRY_LENGTH]
		)

		var entry_err := _read_directory_entry(entry_bytes, bytes)
		if entry_err:
			return entry_err

	return OK


func _read_directory_entry(entry_bytes: PackedByteArray, all_bytes: PackedByteArray) -> Error:
	var lump_read_start := entry_bytes.decode_s32(_ENTRY_START_OFFSET)
	if lump_read_start < 0:
		return ERR_FILE_CORRUPT

	var lump_read_size := entry_bytes.decode_s32(_ENTRY_SIZE_OFFSET)
	if lump_read_size < 0:
		return ERR_FILE_CORRUPT

	var lump_data := all_bytes.slice(lump_read_start, lump_read_start + lump_read_size)
	var lump_data_size := lump_data.size()
	if lump_data_size < lump_read_size:
		return ERR_FILE_EOF

	assert(
		lump_data_size == lump_read_size,
		"Lump size mismatch (got %d, expected %d)" % [lump_data_size, lump_read_size]
	)

	# We are assuming all strings are nul-padded, because
	# it makes parsing *much* simpler, and no modern WAD
	# editors should be writing unpadded anymore.
	var name_bytes := entry_bytes.slice(_ENTRY_NAME_OFFSET, _ENTRY_NAME_OFFSET + Lump.NAME_MAX)
	var lump_name := name_bytes.get_string_from_ascii()

	# TODO: Are empty WAD lump names valid?
	# Are WAD lump names w/ bad characters valid?
	#if (lump_name.is_empty()
	#or not lump_name.is_valid_filename()):
	#	return ERR_FILE_CORRUPT

	var lump := Lump.new(lump_name, lump_data)
	lumps.push_back(lump)

	return OK


## Returns a [PackedByteArray] converted into a [WADFile].
## Returns [code]null[/code] if the bytes were not a valid WAD.
static func decode(bytes: PackedByteArray) -> WADFile:
	var error := Error.FAILED
	var wad := WADFile.new()
	assert(wad != null)

	error = wad._read_identifier(bytes)
	if error:
		return null

	error = wad._read_directory(bytes)
	if error:
		return null

	return wad


# Helper function for encode
static func _append_s32(bytes: PackedByteArray, value: int = 0) -> int:
	var pointer: int = bytes.size()

	var int_bytes: PackedByteArray = []
	int_bytes.resize(4)
	int_bytes.encode_s32(0, value)

	bytes.append_array(int_bytes)
	return pointer


## Returns a [WADFile] converted into a [PackedByteArray].
## Returns an empty array if an error occurred.
static func encode(wad: WADFile) -> PackedByteArray:
	if wad == null:
		return []

	var ret: PackedByteArray = []

	# Write identifier
	if wad.internal:
		ret.append_array(INTERNAL_ID.to_ascii_buffer())
	else:
		ret.append_array(PATCH_ID.to_ascii_buffer())

	# Write lump count
	var num_lumps := wad.lumps.size()
	_append_s32(ret, num_lumps)

	# Reserve room for directory offset
	var dir_pointer_pos := _append_s32(ret)
	assert(
		dir_pointer_pos == _HEADER_DIR_POS,
		"Header directory pointer mismatch (got %d, expected %d)" % [dir_pointer_pos, _HEADER_DIR_POS]
	)

	# Dump all of of the lumps' data, keep track of
	# where they were written to.
	var lump_pointers: Dictionary[Lump, int] = {}
	for lump: Lump in wad.lumps:
		lump_pointers[lump] = ret.size()
		ret.append_array(lump.data)

	# Write dictionary position
	var dir_pointer := ret.size()
	ret.encode_s32(dir_pointer_pos, dir_pointer)

	# Create the dictionary itself
	for lump: Lump in wad.lumps:
		_append_s32(ret, lump_pointers[lump]) # Pointer
		_append_s32(ret, lump.data.size()) # Size

		# Name
		var name_bytes := lump.name.to_ascii_buffer()
		name_bytes.resize(Lump.NAME_MAX)
		ret.append_array(name_bytes)

	return ret
