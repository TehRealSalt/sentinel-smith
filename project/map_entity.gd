class_name DoomEntity
extends Node
## A UDMF map "entity". This is the base type that all map data inherits from.


## Container for any fields that do not have any built-in handling for.
## This can include "user_" fields, and any fields that aren't supported yet.
## Ensures that these are still saved back into the map file.
var _raw_fields: Dictionary[StringName, Variant] = {}


## Virtual function which asserts if this map entity is valid.
## This should be reserved for "crash"-level importance failures.
func _assert() -> bool:
	return true


## Virtual function which describes each UDMF field and its default value.
func _get_field_defaults() -> Dictionary[StringName, Variant]:
	assert(false, "_get_field_defaults was not overridden!")
	return {}


func _init(data: Dictionary) -> void:
	var defaults := _get_field_defaults()
	for id: StringName in defaults.keys():
		var def: Variant = defaults[id]

		if def == null:
			# No default means this field is REQUIRED
			assert(data.has(id))

		_raw_fields[id] = data.get(id, def)
