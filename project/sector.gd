class_name DoomSector
extends DoomEntity
## Represents a sector as it is in the UDMF specification.


## The properties associated with this sector's floor.
var floor_plane := DoomSectorPlane.new(self, false)


## The properties associated with this sector's ceiling.
var ceiling_plane := DoomSectorPlane.new(self, true)


func _entity_identifier() -> StringName:
	return &"sector"


func _entity_fields() -> Dictionary[StringName, EntityField]:
	return {
		&"heightfloor": EntityField.new(TYPE_INT, 0),
		&"heightceiling": EntityField.new(TYPE_INT, 0),
		&"texturefloor": EntityField.new(TYPE_STRING, null),
		&"textureceiling": EntityField.new(TYPE_STRING, null),
		&"lightlevel": EntityField.new(TYPE_INT, 160),
		&"special": EntityField.new(TYPE_INT, 0),
		&"id": EntityField.new(TYPE_INT, 0),
		&"comment": EntityField.new(TYPE_STRING, ""),
	}
