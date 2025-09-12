class_name DoomLinedef
extends DoomEntity
## Represents a linedef as it is in the UDMF specification.


func _entity_identifier() -> StringName:
	return &"linedef"


func _entity_fields() -> Dictionary[StringName, EntityField]:
	return {
		&"id": EntityField.new(TYPE_INT, -1), # -1 should be handled special later
		&"v1": EntityField.new(DoomVertex, null),
		&"v2": EntityField.new(DoomVertex, null),
		&"blocking": EntityField.new(TYPE_BOOL, false),
		&"blockmonsters": EntityField.new(TYPE_BOOL, false),
		&"twosided": EntityField.new(TYPE_BOOL, false),
		&"dontpegtop": EntityField.new(TYPE_BOOL, false),
		&"dontpegbottom": EntityField.new(TYPE_BOOL, false),
		&"secret": EntityField.new(TYPE_BOOL, false),
		&"blocksound": EntityField.new(TYPE_BOOL, false),
		&"dontdraw": EntityField.new(TYPE_BOOL, false),
		&"mapped": EntityField.new(TYPE_BOOL, false),
		&"passuse": EntityField.new(TYPE_BOOL, false),
		&"translucent": EntityField.new(TYPE_BOOL, false),
		&"jumpover": EntityField.new(TYPE_BOOL, false),
		&"blockfloaters": EntityField.new(TYPE_BOOL, false),
		&"playercross": EntityField.new(TYPE_BOOL, false),
		&"playeruse": EntityField.new(TYPE_BOOL, false),
		&"monstercross": EntityField.new(TYPE_BOOL, false),
		&"monsteruse": EntityField.new(TYPE_BOOL, false),
		&"impact": EntityField.new(TYPE_BOOL, false),
		&"playerpush": EntityField.new(TYPE_BOOL, false),
		&"monsterpush": EntityField.new(TYPE_BOOL, false),
		&"missilecross": EntityField.new(TYPE_BOOL, false),
		&"repeatspecial": EntityField.new(TYPE_BOOL, false),
		&"special": EntityField.new(TYPE_INT, 0),
		&"arg0": EntityField.new(TYPE_INT, 0),
		&"arg1": EntityField.new(TYPE_INT, 0),
		&"arg2": EntityField.new(TYPE_INT, 0),
		&"arg3": EntityField.new(TYPE_INT, 0),
		&"arg4": EntityField.new(TYPE_INT, 0),
		&"sidefront": EntityField.new(DoomSidedef, null),
		&"sideback": EntityField.new(DoomSidedef, -1),
		&"comment": EntityField.new(TYPE_STRING, ""),
	}
