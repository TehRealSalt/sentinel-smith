class_name DoomSidedef
extends DoomEntity
## Represents a sidedef as it is in the UDMF specification.


## Offset for ALL textures on this side.
var offset: Vector2 = Vector2.ZERO


## The upper sidedef part.
var top_part: DoomSidedefPart


## The lower sidedef part.
var bottom_part: DoomSidedefPart


## The middle sidedef part.
var middle_part: DoomSidedefPart


## The pointer to the [DoomSector] that this line side is facing.
var sector: DoomSector


func _assert() -> bool:
	if sector == null:
		return false

	return super()
