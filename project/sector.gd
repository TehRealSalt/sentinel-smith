class_name DoomSector
extends DoomEntity
## Represents a sector as it is in the UDMF specification.


## The properties associated with this sector's floor.
var plane_floor := DoomSectorPlane.new(self, false)


## The properties associated with this sector's ceiling.
var plane_ceiling := DoomSectorPlane.new(self, true)


## The light level of the entire sector.
var light_level: int = 160


## The sector's special properties.
var special: int = 0


## This sector's tag.
var tag: int = 0


## All [DoomSidedef]s that reference this sector.
##
## This should [b]not[/b] be modified directly.
## Changing [member DoomSidedef.sector]
## will automatically handle updating this list on all
## involved sectors to be accurate.
var sides: Array[DoomSidedef] = []


func _entity_identifier() -> StringName:
	return &"sector"


func _entity_fields() -> Dictionary[StringName, EntityField]:
	return {
		&"heightfloor": EntityField.new(^':plane_floor:height', 0),
		&"heightceiling": EntityField.new(^':plane_ceiling:height', 0),
		&"texturefloor": EntityField.new(^':plane_floor:texture', null),
		&"textureceiling": EntityField.new(^':plane_ceiling:texture', null),
		&"lightlevel": EntityField.new(^':light_level', 160),
		&"special": EntityField.new(^':special', 0),
		&"id": EntityField.new(^':tag', 0),
		&"comment": EntityField.new(^':comment', ''),
	}
