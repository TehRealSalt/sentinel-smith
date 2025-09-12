class_name DoomEntity
extends Node
## A UDMF map "entity". This is the base type that all map data inherits from.

## A special string reserved for viewing in the map editor.
##
## FIXME: [DoomVertex] does not have this in the UDMF spec.
## Determine if it causes problems if we do not match this exception.
var comment: String = "" 


## Container for any fields that do not have any built-in handling for.
## This can include "user_" fields, and any fields that aren't supported yet.
## Ensures that these are still saved back into the map file.
var extra_fields: Dictionary[String, Variant] = {}


## Virtual function which asserts if this map entity is valid.
## This should be reserved for "crash"-level importance failures.
func _assert() -> bool:
	return true


func _init(data: Dictionary) -> void:
	comment = data.comment
