class_name DoomVertex
extends DoomEntity
## Represents a vertex as it is in the UDMF specification.


func _get_entity_identifier() -> StringName:
	return &"vertex"


func _get_field_defaults() -> Dictionary[StringName, Variant]:
	return {
		&"x": null,
		&"y": null,
	}
