class_name DoomSector
extends DoomEntity
## Represents a sector as it is in the UDMF specification.


## The floor height.
var heightfloor: int = 0


## The ceiling height.
var heightceiling: int = 0


## The floor texture name or path.
var texturefloor: String


## The ceiling texture name or path.
var textureceiling: String


## The light level of this sector.
var lightlevel: int = 160


## The sector "special" property.
## Not to be confused with its "action", which is
## often also referred to by other entities as "special".
var special: int = 0


## The scripting ID (or "tag") of this sector.
var id: int = 0
