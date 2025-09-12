class_name DoomSector
extends DoomEntity
## Represents a sector as it is in the UDMF specification.


## The properties associated with this sector's floor.
var floor_plane := DoomSectorPlane.new(self, false)


## The properties associated with this sector's ceiling.
var ceiling_plane := DoomSectorPlane.new(self, true)


func _get_entity_identifier() -> StringName:
	return &"sector"


func _get_field_defaults() -> Dictionary[StringName, Variant]:
	return {
		&"heightfloor": 0,
		&"heightceiling": 0,
		&"texturefloor": null,
		&"textureceiling": null,
		&"lightlevel": 160,
		&"special": 0,
		&"id": 0,
		&"comment": "",
	}
