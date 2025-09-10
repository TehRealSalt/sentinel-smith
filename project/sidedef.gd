class_name DoomSidedef
extends DoomEntity
## Represents a sidedef as it is in the UDMF specification.


## Texture X offset. Affects all textures.
var offsetx: int = 0


## Texture Y offset. Affects all textures.
var offsety: int = 0


## The texture path that represents a side part with no texture.
const NO_TEXTURE = "-";


## The upper texture name or path.
var texturetop: String = NO_TEXTURE


## The lower texture name or path.
var texturebottom: String = NO_TEXTURE


## The middle texture name or path.
var texturemiddle: String = NO_TEXTURE


## The pointer to the [DoomSector] that this line side is facing.
var sector: DoomSector


func _assert() -> bool:
	if sector == null:
		return false

	return super()
