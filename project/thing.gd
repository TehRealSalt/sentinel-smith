class_name DoomThing
extends DoomEntity
## Represents a "thing" as it is in the UDMF specification.
## These are objects that are defined per configuration.

## The scripting ID (or "TID") of this thing.
var id: int = 0


## X coordinate.
var x: float


## Y coordinate.
var y: float


## Z coordinate, relative to the sector's height.
var height: float = 0.0


## Angle, in degrees. 0 should face east.
var angle: int = 0


## The "DoomEdNum" of this thing.
var type: int


# Thing flags

## Appears in skill 1 (baby)
var skill1: bool = false


## Appears in skill 2 (easy)
var skill2: bool = false


## Appears in skill 3 (normal)
var skill3: bool = false


## Appears in skill 4 (hard)
var skill4: bool = false


## Appears in skill 5 (nightmare)
var skill5: bool = false


## Enemy attempts to ambush the player.
var ambush: bool = false


## Can spawn in single-player mode.
var single: bool = false


## Can spawn in deathmatch mode.
var dm: bool = false


## Can spawn in coop mode.
var coop: bool = false


# MBF flags, ignored in Heretic/Hexen/Strife.

## MBF-style "friendly" NPC.
var friend: bool = false


# Hexen flags, ignored in Doom/Heretic/Strife.

## This object is inactive until it is activated via scripting.
var dormant: bool = false


## Appears for class 1 (fighter)
var class1: bool = false


## Appears for class 2 (cleric)
var class2: bool = false


## Appears for class 3 (mage)
var class3: bool = false


# Strife flags, ignored in non-ZDoom.

## Is a Strife NPC.
var standing: bool = false


## Strife-style "friendly" NPC.
var strifeally: bool = false


## Strife-style 50% transulcent.
var translucent: bool = false


## Strife-style invisible.
var invisible: bool = false


# Actions. This should be ignored in map formats that do not implement scripting

## This thing's action.
var special: int = 0


## [member special]'s argument 0.
var arg0: int = 0


## [member special]'s argument 1.
var arg1: int = 0


## [member special]'s argument 2.
var arg2: int = 0


## [member special]'s argument 3.
var arg3: int = 0


## [member special]'s argument 4.
var arg4: int = 0


## Gets this thing's script arguments as an array.
func get_args() -> Array:
	return [arg0, arg1, arg2, arg3, arg4]


## Sets this thing's script arguments from an array.
func set_args(v: Array) -> void:
	assert(v.size() == 5)
	arg0 = v[0]
	arg1 = v[1]
	arg2 = v[2]
	arg3 = v[3]
	arg4 = v[4]
