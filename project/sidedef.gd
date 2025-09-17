class_name DoomSidedef
extends DoomEntity
## Represents a sidedef as it is in the UDMF specification.


## The texture path that represents a side part with no texture.
const NO_TEXTURE := "-"


## Represents the IDs of [DoomSidedefPart] types. See also: [member parts].
enum Parts
{
	TOP,
	BOTTOM,
	MIDDLE,
}


## Represents the different [DoomSidedefPart]s of this sidedef.
var parts: Dictionary[Parts, DoomSidedefPart] = {
	Parts.TOP: DoomSidedefPart.new(self, Parts.TOP),
	Parts.BOTTOM: DoomSidedefPart.new(self, Parts.BOTTOM),
	Parts.MIDDLE: DoomSidedefPart.new(self, Parts.MIDDLE),
}


## Called after changing the UDMF state sector. Updates the associated sectors'
## [member DoomSector.sides] list.
func on_sector_change(prev_sector: DoomSector, new_sector: DoomSector) -> void:
	if prev_sector != null:
		prev_sector.sides.erase(self)

	if new_sector != null:
		new_sector.sides.append(self)


func _entity_identifier() -> StringName:
	return &"sidedef"


func _entity_fields() -> Dictionary[StringName, EntityField]:
	return {
		&"offsetx": EntityField.new(TYPE_INT, 0),
		&"offsety": EntityField.new(TYPE_INT, 0),
		&"texturetop": EntityField.new(TYPE_STRING, NO_TEXTURE),
		&"texturebottom": EntityField.new(TYPE_STRING, NO_TEXTURE),
		&"texturemiddle": EntityField.new(TYPE_STRING, NO_TEXTURE),
		&"sector": EntityField.new(DoomSector, null, on_sector_change),
		&"comment": EntityField.new(TYPE_STRING, ""),
	}
