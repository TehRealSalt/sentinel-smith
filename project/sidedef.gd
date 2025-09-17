class_name DoomSidedef
extends DoomEntity
## Represents a sidedef as it is in the UDMF specification.


## The texture path that represents a side part with no texture.
const NO_TEXTURE := "-"


## Represents the IDs of [DoomSidedefPart] types.
enum Parts
{
	TOP,
	BOTTOM,
	MIDDLE,
}


## The upper [DoomSidedefPart].
var part_top := DoomSidedefPart.new(self, Parts.TOP)


## The lower [DoomSidedefPart].
var part_bottom := DoomSidedefPart.new(self, Parts.BOTTOM)


## The middle [DoomSidedefPart].
var part_middle := DoomSidedefPart.new(self, Parts.MIDDLE)


## Global texture offset; applies to all of this side's [DoomSidedefPart]s.
var offset: Vector2 = Vector2.ZERO


## The [DoomSector] that this side faces.
##
## Modifying this will automatically change both the old and new
## [member DoomSector.sides] to be accurate.
var sector: DoomSector = null:
	set(new_sector):
		if sector != null:
			sector.sides.erase(self)
		if new_sector != null:
			new_sector.sides.append(self)
		sector = new_sector


## All [DoomLinedef]s that reference this side.
##
## This should [b]not[/b] be modified directly.
## Changing [member DoomLinedef.side_front] or [member DoomLinedef.side_back]
## will automatically handle updating this list on all
## involved sides to be accurate.
var lines: Array[DoomLinedef] = []


func _entity_identifier() -> StringName:
	return &"sidedef"


func _entity_fields() -> Dictionary[StringName, EntityField]:
	return {
		&"offsetx": EntityField.new(^':offset:x', 0),
		&"offsety": EntityField.new(^':offset:y', 0),
		&"texturetop": EntityField.new(^':part_top:texture', NO_TEXTURE),
		&"texturebottom": EntityField.new(^':part_bottom:texture', NO_TEXTURE),
		&"texturemiddle": EntityField.new(^':part_middle:texture', NO_TEXTURE),
		&"sector": EntityField.new(^':sector', null, DoomSector),
		&"comment": EntityField.new(^':comment', ""),
	}
