class_name DoomThing
extends DoomEntity
## Represents a "thing" as it is in the UDMF specification.
## These are objects that are defined per configuration.


func _entity_identifier() -> StringName:
	return &"thing"


func _entity_fields() -> Dictionary[StringName, EntityField]:
	return {
		&"id": EntityField.new(TYPE_INT, 0),
		&"x": EntityField.new(TYPE_FLOAT, null),
		&"y": EntityField.new(TYPE_FLOAT, null),
		&"height": EntityField.new(TYPE_FLOAT, 0.0),
		&"angle": EntityField.new(TYPE_INT, 0),
		&"type": EntityField.new(TYPE_INT, null),
		&"skill1": EntityField.new(TYPE_BOOL, false),
		&"skill2": EntityField.new(TYPE_BOOL, false),
		&"skill3": EntityField.new(TYPE_BOOL, false),
		&"skill4": EntityField.new(TYPE_BOOL, false),
		&"skill5": EntityField.new(TYPE_BOOL, false),
		&"ambush": EntityField.new(TYPE_BOOL, false),
		&"single": EntityField.new(TYPE_BOOL, false),
		&"dm": EntityField.new(TYPE_BOOL, false),
		&"coop": EntityField.new(TYPE_BOOL, false),
		&"friend": EntityField.new(TYPE_BOOL, false),
		&"dormant": EntityField.new(TYPE_BOOL, false),
		&"class1": EntityField.new(TYPE_BOOL, false),
		&"class2": EntityField.new(TYPE_BOOL, false),
		&"class3": EntityField.new(TYPE_BOOL, false),
		&"standing": EntityField.new(TYPE_BOOL, false),
		&"strifeally": EntityField.new(TYPE_BOOL, false),
		&"translucent": EntityField.new(TYPE_BOOL, false),
		&"invisible": EntityField.new(TYPE_BOOL, false),
		&"special": EntityField.new(TYPE_INT, 0),
		&"arg0": EntityField.new(TYPE_INT, 0),
		&"arg1": EntityField.new(TYPE_INT, 0),
		&"arg2": EntityField.new(TYPE_INT, 0),
		&"arg3": EntityField.new(TYPE_INT, 0),
		&"arg4": EntityField.new(TYPE_INT, 0),
		&"comment": EntityField.new(TYPE_STRING, ""),
	}
