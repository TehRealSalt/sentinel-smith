class_name DoomThing
extends DoomEntity
## Represents a "thing" as it is in the UDMF specification.
## These are objects that are defined per configuration.

func _get_field_defaults() -> Dictionary[StringName, Variant]:
	return {
		&"id": 0,
		&"x": null,
		&"y": null,
		&"height": 0,
		&"angle": 0,
		&"type": null,
		&"skill1": false,
		&"skill2": false,
		&"skill3": false,
		&"skill4": false,
		&"skill5": false,
		&"ambush": false,
		&"single": false,
		&"dm": false,
		&"coop": false,
		&"friend": false,
		&"dormant": false,
		&"class1": false,
		&"class2": false,
		&"class3": false,
		&"standing": false,
		&"strifeally": false,
		&"translucent": false,
		&"invisible": false,
		&"special": 0,
		&"arg0": 0,
		&"arg1": 0,
		&"arg2": 0,
		&"arg3": 0,
		&"arg4": 0,
		&"comment": "",
	}
