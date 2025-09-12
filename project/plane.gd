class_name DoomSectorPlane
extends RefCounted
## Represents a [DoomSector]'s floor and ceiling planes.
## This isn't a thing in the UDMF spec, but it reduce code duplication
## for more complicated map formats.

## The plane's vertical coordinate.
var height: int = 0

## The plane's texture name or path.
var texture: String
