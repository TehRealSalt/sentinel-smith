class_name DoomSidedef
extends DoomEntity
## Represents a sidedef as it is in the UDMF specification.


## The texture path that represents a side part with no texture.
const NO_TEXTURE = "-";


enum Parts
{
	TOP,
	BOTTOM,
	MIDDLE,
}


var parts: Dictionary[Parts, DoomSidedefPart] = {
	Parts.TOP: DoomSidedefPart.new(self, Parts.TOP),
	Parts.BOTTOM: DoomSidedefPart.new(self, Parts.BOTTOM),
	Parts.MIDDLE: DoomSidedefPart.new(self, Parts.MIDDLE),
}


func _entity_identifier() -> StringName:
	return &"sidedef"


func _entity_fields() -> Dictionary[StringName, EntityField]:
	return {
		&"offsetx": EntityField.new(TYPE_INT, 0),
		&"offsety": EntityField.new(TYPE_INT, 0),
		&"texturetop": EntityField.new(TYPE_STRING, NO_TEXTURE),
		&"texturebottom": EntityField.new(TYPE_STRING, NO_TEXTURE),
		&"texturemiddle": EntityField.new(TYPE_STRING, NO_TEXTURE),
		&"sector": EntityField.new(DoomSector, null),
		&"comment": EntityField.new(TYPE_STRING, ""),
	}
