class_name DoomLinedef
extends DoomEntity
## Represents a linedef as it is in the UDMF specification.


func _get_entity_identifier() -> StringName:
	return &"linedef"


func _get_field_defaults() -> Dictionary[StringName, Variant]:
	return {
		&"id": -1,
		&"v1": null,
		&"v2": null,
		&"blocking": false,
		&"blockmonsters": false,
		&"twosided": false,
		&"dontpegtop": false,
		&"dontpegbottom": false,
		&"secret": false,
		&"blocksound": false,
		&"dontdraw": false,
		&"mapped": false,
		&"passuse": false,
		&"translucent": false,
		&"jumpover": false,
		&"blockfloaters": false,
		&"playercross": false,
		&"playeruse": false,
		&"monstercross": false,
		&"monsteruse": false,
		&"impact": false,
		&"playerpush": false,
		&"monsterpush": false,
		&"missilecross": false,
		&"repeatspecial": false,
		&"special": 0,
		&"arg0": 0,
		&"arg1": 0,
		&"arg2": 0,
		&"arg3": 0,
		&"arg4": 0,
		&"sidefront": null,
		&"sideback": -1,
		&"comment": "",
	}
