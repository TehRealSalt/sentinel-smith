@abstract
class_name DoomEntity
extends Node
## A UDMF map "entity". This is the base type that all map data inherits from.

## The [DoomMap] that we belong to.
var map: DoomMap = null


## Comment. Nearly every entity has this.
var comment: String = ''


## Represents properties about one of our fields.
class EntityField:
	## The [NodePath] to the Godot property that this UDMF field links to.
	var path: NodePath

	## The default value to initialize to,
	## when the map does not have it specified.
	var default: Variant = null

	## The script that this field corresponds with.
	var entity_script: Script = null

	func _init(p_path: NodePath, p_def: Variant = null, p_script: Script = null) -> void:
		path = p_path.get_as_property_path()
		default = p_def
		entity_script = p_script


## Container for this entity's user / under-specified UDMF fields.
var user_state: Dictionary[StringName, Variant] = {}


## Returns the name that this entity goes by in the UDMF spec.
@abstract
func _entity_identifier() -> StringName


## Returns a description of each UDMF field, their types,
## and their default values. See also: [class EntityField].
@abstract
func _entity_fields() -> Dictionary[StringName, EntityField]


## Returns our entity index in our [member map].
func _entity_index() -> int:
	return map.entity_type_to_array[get_script()].find(self)


func _get_field_string(key: StringName, value: Variant, type: Variant.Type, script: Script, default: Variant) -> String:
	if script != null:
		# Entities are stored by their index
		type = TYPE_INT

		if value == null:
			value = -1
		else:
			var obj: Object = type_convert(value, TYPE_OBJECT)
			var ent := obj as DoomEntity
			value = ent._entity_index()

	if (default != null
	and value == default):
		return ""

	assert(value != null)

	var str_value: String = ''
	if type == TYPE_STRING:
		str_value = '"%s"' % value
	else:
		str_value = str(value)

	return "\t%s = %s;" % [key, str_value]


func _to_string() -> String:
	var fields := _entity_fields()
	var ret: PackedStringArray = []

	ret.push_back(_entity_identifier())
	ret.push_back("{")

	for key: StringName in fields.keys():
		var field := fields[key]
		var value: Variant = get_indexed(field.path)
		var type: Variant.Type = typeof(value) as Variant.Type
		var write := _get_field_string(key, value, type, field.entity_script, field.default)
		if not write.is_empty():
			ret.push_back(write)

	for key: StringName in user_state.keys():
		var value: Variant = user_state[key]
		var type: Variant.Type = typeof(value) as Variant.Type
		var write := _get_field_string(key, value, type, null, null)
		if not write.is_empty():
			ret.push_back(write)

	ret.push_back("}")
	return '\n'.join(ret)


func _init(from_map: DoomMap, data: Dictionary) -> void:
	map = from_map
	map.add_child(self)

	var fields := _entity_fields()

	# First, load explicitly-defined fields.
	# This needs to be done fully before doing user fields.
	for id: StringName in fields.keys():
		var field: EntityField = fields.get(id, null)
		if field.default == null:
			# No default means this field is REQUIRED
			assert(data.has(id), 'UDMF map is missing required field "%s"' % id)

		var value: Variant = null
		if field.entity_script != null:
			var index: int = data.get(id, -1)
			if (index < 0 and field.default != null):
				# Pointer is allowed to be omitted
				value = null
			else:
				value = map.get_entity_pointer(field.entity_script, index)
				assert(is_instance_valid(value))
		else:
			value = data.get(id, field.default)

		set_indexed(field.path, value)

	# Load all under-specified fields as
	# un-typed user properties.
	for id: StringName in data.keys():
		if id in fields.keys():
			continue

		var value: Variant = data.get(id, null)
		if value != null:
			user_state[id] = value
