class_name DoomLinedef
extends DoomEntity
## Represents a linedef as it is in the UDMF specification.

## The scripting ID (or "tag") of this line.
var id: int = -1 # TODO: Has a special default based on map format.


# Vertex pointers

## A pointer to this line's first [DoomVertex].
## Expected to always be valid.
var v1: DoomVertex


## A pointer to this line's second [DoomVertex].
## Expected to always be valid.
var v2: DoomVertex


# Flag values, should always default to "false".

## This line blocks actors.
var blocking: bool = false


## This line blocks enemies.
var blockmonsters: bool = false


## This line has more than one side.
var twosided: bool = false


## Upper texture is un-pegged.
var dontpegtop: bool = false


## Lower texture is un-pegged.
var dontpegbottom: bool = false


## Drawn as one-sided on the map.
var secret: bool = false


## Blocks enemies' ability to wake up from player sounds.
var blocksound: bool = false


## Prevents drawing on the automap.
var dontdraw: bool = false


## Always draws on the automap, regardless of if the player has seen it yet.
var mapped: bool = false


## Passes "use" actions.
##
## This flag is from Boom.
## This is not supported in Heretic, Hexen, and Strife namespaces.
var passuse: bool = false


# Strife flags. These should be ignored when reading maps not for Strife,
# or for source ports that don't implement these flags.

## "Strife"-style translucency.
var translucent: bool = false


## "Strife"-style jump-over railing.
var jumpover: bool = false


## "Strife"-style block floating enemies.
var blockfloaters: bool = false


# Activation flags. These should be ignored outside of map formats with
# scripting (Doom, Heretic, and Strife).

## Activates when a player crosses from one side to the other.
var playercross: bool = false


## Activates when a player presses their "use" key on this line.
var playeruse: bool = false


## Activates when an enemy crosses from one side to the other.
var monstercross: bool = false


## Activates when an enemy walks into it, and wants to use it. (doors)
var monsteruse: bool = false


## Activates when a projectile explodes against this line.
var impact: bool = false


## Activates when a player is blocked by the line.
var playerpush: bool = false


## Activates when an enemy is blocked by the line.
var monsterpush: bool = false


## Activates when a projectile crosses from one side to the other.
var missilecross: bool = false


## Allows the action to activate more than once.
var repeatspecial: bool = false


# Actions

## This line's action.
var special: int = 0


## [member special]'s argument 0.
##
## In map formats without scripting, this should be equal to [member id].
var arg0: int = 0


## [member special]'s argument 1.
var arg1: int = 0


## [member special]'s argument 2.
var arg2: int = 0


## [member special]'s argument 3.
var arg3: int = 0


## [member special]'s argument 4.
var arg4: int = 0


## Gets this line's script arguments as an array.
func get_args() -> Array:
	return [arg0, arg1, arg2, arg3, arg4]


## Sets this line's script arguments from an array.
func set_args(v: Array) -> void:
	assert(v.size() == 5)
	arg0 = v[0]
	arg1 = v[1]
	arg2 = v[2]
	arg3 = v[3]
	arg4 = v[4]


# Sidedef pointers

## A pointer to this line's front [DoomSidedef].
## Expected to always be valid.
var sidefront: DoomSidedef


## A pointer to this line's second [DoomSidedef].
## May be [code]null[/code] if the line is not two-sided.
var sideback: DoomSidedef = null


func _assert() -> bool:
	if (v1 == null
	or v2 == null
	or sidefront == null):
		return false

	return super()
