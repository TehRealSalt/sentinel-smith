class_name DoomEntity
extends Node
## A UDMF map "entity". This is the base type that all map data inherits from.

## The [DoomMap] that we belong to.
var map: DoomMap = null


## Represents properties about one of our fields.
class EntityField:
	var type: Variant
	var default: Variant

	func _init(p_type: Variant, p_def: Variant = null) -> void:
		type = p_type
		default = p_def


## Container for this entity's UDMF state.
var _state: Dictionary[StringName, Variant] = {}


## Container for this entity's user / under-specified state.
var _state_user: Dictionary[StringName, Variant] = {}


## Returns the name that this entity goes by in the UDMF spec.
func _entity_identifier() -> StringName:
	assert(false, "_entity_identifier was not overridden!")
	return &""


## Returns a description of each UDMF field, their types,
## and their default values. See also: [class EntityField].
func _entity_fields() -> Dictionary[StringName, EntityField]:
	assert(false, "_entity_fields was not overridden!")
	return {}


## Returns our entity index in our [member map].
func _entity_index() -> int:
	return map.entity_type_to_array[get_script()].find(self)


func _get_property_list() -> Array[Dictionary]:
	var ret: Array[Dictionary] = []

	var fields := _entity_fields()
	for key: StringName in fields.keys():
		var prop: Dictionary = {}
		prop.name = key

		var type: Variant = fields[key].type
		if type is Object:
			prop.type = TYPE_OBJECT
			var obj: Object = type_convert(type, TYPE_OBJECT)
			var script: Script = obj.get_script()
			prop.class_name = script.get_global_name()
		else:
			prop.type = type

		ret.push_back(prop)

	for key: StringName in _state_user.keys():
		assert(not (key in _state))

		var prop: Dictionary = {}
		prop.name = key
		prop.type = typeof(_state_user)

		ret.push_back(prop)

	return ret


func _get(id: StringName) -> Variant:
	if _state.has(id):
		return _state[id]

	return _state_user.get(id)


func _set(id: StringName, value: Variant) -> bool:
	if _state.has(id):
		var fields := _entity_fields()
		var new_type := typeof(value)
		var defined_type: Variant = fields[id].type
		if defined_type is Object:
			var defined_obj: Object = type_convert(defined_type, TYPE_OBJECT)
			if new_type != TYPE_NIL:
				assert(new_type == TYPE_OBJECT)
				var obj: Object = type_convert(value, TYPE_OBJECT)
				var script: Script = obj.get_script()
				assert(script == (defined_obj as Script))
		else:
			assert(new_type == defined_type)
		
		_state[id] = value
		return true

	_state_user[id] = value
	return true


func _to_string() -> String:
	var fields := _entity_fields()
	var ret: String = ""

	ret += _entity_identifier()
	ret += "\n{"

	for key: StringName in _state.keys():
		var existing_field := fields[key]
		var val: Variant = _state[key]

		if val == null:
			assert(existing_field.type in map.entity_type_to_array.keys())
			val = -1
		elif val is Object:
			assert(existing_field.type in map.entity_type_to_array.keys())
			var obj: Object = type_convert(val, TYPE_OBJECT)
			var ent := obj as DoomEntity
			val = ent._entity_index()

		if typeof(val) == TYPE_STRING:
			val = '"%s"' % val # Give it double quotes

		if (existing_field == null
		or val != existing_field.default):
			ret += "\n\t%s = %s;" % [key, val]

	for key: StringName in _state_user.keys():
		var val: Variant = _state_user[key]
		if val == null:
			continue
		assert(not (val is Object))

		if typeof(val) == TYPE_STRING:
			val = '"%s"' % val # Give it double quotes

		ret += "\n\t%s = %s;" % [key, val]

	ret += "\n}"
	return ret


func _init(from_map: DoomMap, data: Dictionary) -> void:
	map = from_map

	# First, load 
	var fields := _entity_fields()
	for id: StringName in fields.keys():
		var field: EntityField = fields[id]

		if field.default == null:
			# No default means this field is REQUIRED
			assert(data.has(id))

		var set_val: Variant = null
		if field.type is Object:
			assert(field.type in map.entity_type_to_array.keys())

			var obj: Object = type_convert(field.type, TYPE_OBJECT)
			var ent_type: Script = (obj as Script)

			var index: int = data.get(id, -1)
			if (index < 0 and field.default != null):
				# Pointer is allowed to be omitted
				set_val = null
			else:
				set_val = map.get_entity_pointer(ent_type, index)
				assert(is_instance_valid(set_val))
		else:
			set_val = data.get(id, field.default)
			assert(
				is_instance_of(set_val, field.type),
				"[%s]: Expected type %s, got %s" % [id, str(field.type), type_string(typeof(set_val))]
			)

		_state[id] = set_val

	# Load all underspecified fields as
	# untyped user properties
	for id: StringName in data.keys():
		if _state.has(id):
			continue
		_state_user[id] = data.get(id, null)

	map.add_child(self)
