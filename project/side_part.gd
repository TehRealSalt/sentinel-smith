class_name DoomSidedefPart
extends DoomEntityMirror
## Represents a [DoomSidedef]'s upper, middle, and lower "parts".

var which_part: DoomSidedef.Parts


func _mirrored_fields() -> Dictionary[StringName, StringName]:
	match which_part:
		DoomSidedef.Parts.TOP:
			return {
				&"texture": &"texturetop",
			}
		DoomSidedef.Parts.BOTTOM:
			return {
				&"texture": &"texturebottom",
			}
		DoomSidedef.Parts.MIDDLE:
			return {
				&"texture": &"texturemiddle",
			}
		_:
			assert(false)
			return {}


func _init(side: DoomSidedef, which: DoomSidedef.Parts) -> void:
	super(side)
	which_part = which
