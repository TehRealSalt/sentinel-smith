class_name DoomSidedefPart
extends RefCounted
## Represents a [DoomSidedef]'s upper, middle, and lower "parts".


## The [DoomSidedef] that this part belongs to.
var side: DoomSidedef


## Which part of the sidedef that this is.
var which: DoomSidedef.Parts


## This part's texture name / file path.
var texture: String = DoomSidedef.NO_TEXTURE


func _init(p_side: DoomSidedef, p_which: DoomSidedef.Parts) -> void:
	side = p_side
	which = p_which
