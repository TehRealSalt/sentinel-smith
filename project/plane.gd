class_name DoomSectorPlane
extends DoomEntityMirror
## Represents a mirror for [DoomSector]'s floor and ceiling planes.

var is_ceiling := false


func _mirrored_fields() -> Dictionary[StringName, StringName]:
	if is_ceiling:
		return {
			&"height": &"heightceiling",
			&"texture": &"textureceiling",
		}
	else:
		return {
			&"height": &"heightfloor",
			&"texture": &"textureceiling",
		}


func _init(sector: DoomSector, ceiling: bool) -> void:
	super(sector)
	is_ceiling = ceiling
