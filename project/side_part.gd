class_name DoomSidedefPart
extends RefCounted
## Represents a [DoomSidedef]'s upper, middle, and lower "parts".
## This isn't a thing in the UDMF spec, but it reduce code duplication
## for more complicated map formats.


## The texture path that represents a side part with no texture.
const NO_TEXTURE = "-";


## This side part's texture name or path.
var texture: String = NO_TEXTURE
