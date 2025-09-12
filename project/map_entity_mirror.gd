class_name DoomEntityMirror
extends RefCounted
## Represents a map structure that doesn't technically exist, but helps reduce
## code duplication to refer to it by.
##
## A good, working example:
## [DoomSectorPlane] simply mirrors several fields present on [DoomSector],
## which allows for holding a pointer to *just* the single plane's properties.


var _mirroring: DoomEntity


## Returns a description of all fields that are mirrored.
func _mirrored_fields() -> Dictionary[StringName, StringName]:
	assert(false, "_mirrored_fields was not overridden!")
	return {}


func _init(ent: DoomEntity) -> void:
	assert(ent != null)
	_mirroring = ent
