class_name DoomSectorPlane
extends RefCounted
## Represents a [DoomSector]'s floor and ceiling planes.


## The [DoomSector] that this plane belongs to.
var sector: DoomSector


## If [code]true[/code], this is a ceiling plane.
## Otherwise, it's a floor plane.
var is_ceiling: bool = false


## This sector's Z coordinate.
var height: int = 0


## This plane's texture name / file path.
var texture: String


func _init(p_sector: DoomSector, p_ceiling: bool) -> void:
	sector = p_sector
	is_ceiling = p_ceiling
