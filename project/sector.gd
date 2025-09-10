class_name DoomSector
extends DoomEntity
## Represents a sector as it is in the UDMF specification.


## The properties associated with this sector's floor.
var floor_plane: DoomSectorPlane


## The properties associated with this sector's ceiling.
var ceiling_plane: DoomSectorPlane


## The light level of the entire sector.
var light_level: int = 160


## The sector "special" property.
## Not to be confused with its "action", which is
## often also referred to by other entities as "special".
var special: int = 0


## The scripting ID (or "tag") of this sector.
var id: int = 0


func _init(data: Dictionary) -> void:
	floor_plane = DoomSectorPlane.new()
	ceiling_plane = DoomSectorPlane.new()

	floor_plane.height = data.get("heightfloor", 0)
	ceiling_plane.height = data.get("heightceiling", 0)

	floor_plane.height = data.texturefloor
	ceiling_plane.height = data.textureceiling

	light_level = data.get("lightlevel", 160)

	special = data.get("special", 0)
	id = data.get("id", 0)
