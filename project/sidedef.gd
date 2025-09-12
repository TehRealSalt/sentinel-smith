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


## The upper sidedef part.
var parts: Dictionary[Parts, DoomSidedefPart] = {
	Parts.TOP: DoomSidedefPart.new(self, Parts.TOP),
	Parts.BOTTOM: DoomSidedefPart.new(self, Parts.BOTTOM),
	Parts.MIDDLE: DoomSidedefPart.new(self, Parts.MIDDLE),
}


func _get_field_defaults() -> Dictionary[StringName, Variant]:
	return {
		&"offsetx": 0,
		&"offsety": 0,
		&"texturetop": NO_TEXTURE,
		&"texturebottom": NO_TEXTURE,
		&"texturemiddle": NO_TEXTURE,
		&"sector": null,
		&"comment": "",
	}
