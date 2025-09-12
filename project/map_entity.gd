class_name DoomEntity
extends Node
## A UDMF map "entity". This is the base type that all map data inherits from.


## Container for all fields.
var _raw_fields: Dictionary[StringName, Variant] = {}


## Virtual function which asserts if this map entity is valid.
## This should be reserved for "crash"-level importance failures.
func _assert() -> bool:
	return true


## Returns the name that this entity goes by in the UDMF spec.
func _get_entity_identifier() -> StringName:
	assert(false, "_get_entity_identifier was not overridden!")
	return &""


## Returns a description of each UDMF field and its default value.
func _get_field_defaults() -> Dictionary[StringName, Variant]:
	assert(false, "_get_field_defaults was not overridden!")
	return {}


func _to_string() -> String:
	var defaults := _get_field_defaults()
	var ret: String = ""

	ret += _get_entity_identifier()
	ret += "\n{"
	for key: StringName in _raw_fields.keys():
		var val: Variant = _raw_fields[key]
		if val != defaults[key]:
			ret += "\n\t%s = %s;" % [key, _raw_fields[key]]
	ret += "\n}"

	return ret


func _init(data: Dictionary) -> void:
	var defaults := _get_field_defaults()
	for id: StringName in defaults.keys():
		var def: Variant = defaults[id]

		if def == null:
			# No default means this field is REQUIRED
			assert(data.has(id))

		_raw_fields[id] = data.get(id, def)
