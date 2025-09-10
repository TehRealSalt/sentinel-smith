class_name DoomThing
extends DoomEntity
## Represents a "thing" as it is in the UDMF specification.
## These are objects that are defined per configuration.

## The scripting ID (or "TID") of this thing.
var id: int


## 2D coordinates.
var pos: Vector2


## Vertical coordinate, relative to the sector's height.
var height: float


## Angle, in degrees. 0 should face east.
var angle: int


## The "DoomEdNum" of this thing.
var type: int


# Thing flags

## Appears in certain skills
var skills: Array[bool]


## Enemy attempts to ambush the player.
var ambush: bool


## Can spawn in single-player mode.
var single: bool


## Can spawn in deathmatch mode.
var dm: bool


## Can spawn in coop mode.
var coop: bool


# MBF flags, ignored in Heretic/Hexen/Strife.

## MBF-style "friendly" NPC.
var friend: bool


# Hexen flags, ignored in Doom/Heretic/Strife.

## This object is inactive until it is activated via scripting.
var dormant: bool


## Appears for certain classes
var classes: Array[bool]


# Strife flags, ignored in non-ZDoom.

## Is a Strife NPC.
var standing: bool


## Strife-style "friendly" NPC.
var strifeally: bool


## Strife-style 50% transulcent.
var translucent: bool


## Strife-style invisible.
var invisible: bool


# Actions. This should be ignored in map formats that do not implement scripting

## This thing's action.
var special: int


## [member special]'s integer arguments.
var int_args: Array[int]


## Gets this thing's script arguments as an array.
## This 
func get_args() -> Array:
	return int_args


## Sets this thing's script arguments from an array.
func set_args(v: Array) -> void:
	assert(v.size() == 5)
	int_args = v


func _init(data: Dictionary) -> void:
	id = data.get("id", 0)
	pos.x = data.x
	pos.y = data.y
	height = data.get("height", 0)
	angle = data.get("angle", 0)
	type = data.type

	skills.resize(5)
	skills[0] = data.get("skill1", false)
	skills[1] = data.get("skill2", false)
	skills[2] = data.get("skill3", false)
	skills[3] = data.get("skill4", false)
	skills[4] = data.get("skill5", false)

	ambush = data.get("ambush", false)
	single = data.get("single", false)
	dm = data.get("dm", false)
	coop = data.get("coop", false)

	friend = data.get("friend", false)

	dormant = data.get("dormant", false)
	classes.resize(3)
	classes[0] = data.get("class1", false)
	classes[1] = data.get("class2", false)
	classes[2] = data.get("class3", false)

	standing = data.get("standing", false)
	strifeally = data.get("strifeally", false)
	translucent = data.get("translucent", false)
	invisible = data.get("invisible", false)

	special = data.get("special", 0)
	int_args.resize(5)
	int_args[0] = data.get("arg0", 0)
	int_args[1] = data.get("arg1", 0)
	int_args[2] = data.get("arg2", 0)
	int_args[3] = data.get("arg3", 0)
	int_args[4] = data.get("arg4", 0)
