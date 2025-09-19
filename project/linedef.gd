class_name DoomLinedef
extends DoomEntity
## Represents a linedef as it is in the UDMF specification.


## This linedef's tag, sometimes referred to as its ID.
##
## The default value of [code]-1[/code] is handled special,
## and is replaced depending on if the map format supports
## action arguments or not.
var tag: int = -1


## This linedef's "starting" [DoomVertex].
##
## Line facing normal depends on the order of this and [member v2].
var v1: DoomVertex = null:
	set(new_v):
		if v1 != null:
			v1.lines.erase(self)
		if new_v != null:
			new_v.lines.append(self)
		v1 = new_v


## This linedef's "ending" [DoomVertex].
##
## Line facing normal depends on the order of this and [member v1].
var v2: DoomVertex = null:
	set(new_v):
		if v2 != null:
			v2.lines.erase(self)
		if new_v != null:
			new_v.lines.append(self)
		v2 = new_v


## If [code]true[/code], this blocks all player and enemy [DoomThing]s.
var blocking: bool = false


## If [code]true[/code], this blocks all enemy [DoomThing]s.
var blockmonsters: bool = false


## If [code]true[/code], this line has a back [DoomSidedef].
## Otherwise, it only has a front side.
var twosided: bool = false


## If [code]true[/code], this alters texture "pegging" behavior.
##
## TODO: Exact description
var dontpegtop: bool = false


## If [code]true[/code], this alters texture "pegging" behavior.
##
## TODO: Exact description
var dontpegbottom: bool = false


## If [code]true[/code], this line is shown as one-sided on the automap.
var secret: bool = false


## If [code]true[/code], this line contributes to blocking sound propagation.
##
## This controls enemies hearing the player's attacks.
## It does not affect the players' ability to hear sound effects.
##
## A sound has to hit two sound blocking lines before it will stop propagating.
var blocksound: bool = false


## If [code]true[/code], this line is [i]never[/i] shown on the automap.
var dontdraw: bool = false


## If [code]true[/code], this line is [i]always[/i] shown on the automap.
var mapped: bool = false


## If [code]true[/code], this line allows more than one "use" key action to
## go through it. Otherwise, line activation will block further use actions.
##
## This is a Doom/Boom flag; behavior is undefined for Heretic/Hexen/Strife.
var passuse: bool = false


## If [code]true[/code], this line is ??% translucent.
## TODO: How translucent? UDMF spec doesn't define, and OG Strife has two flags?
##
## This is a Strife flag; behavior is undefined for Doom/Heretic/Hexen.
var translucent: bool = false


## If [code]true[/code], this line is a Strife-style "jump-over railing".
## This blocks all [DoomThing]s that are less than 32 units of the floor.
##
## This is a Strife flag; behavior is undefined for Doom/Heretic/Hexen.
var jumpover: bool = false


## If [code]true[/code], this line blocks only floating enemy [DoomThing]s.
##
## This is a Strife flag; behavior is undefined for Doom/Heretic/Hexen.
var blockfloaters: bool = false


## If [code]true[/code], this line activates [member action] when
## a player crosses from one side to the other.
##
## If the map format does not support action arguments, then this is
## specified directly by [member action].
var playercross: bool = false


## If [code]true[/code], this line activates [member action] when
## a player presses the "use" button within range.
##
## If the map format does not support action arguments, then this is
## specified directly by [member action].
var playeruse: bool = false


## If [code]true[/code], this line activates [member action] when
## an enemy crosses from one side to the other.
##
## If the map format does not support action arguments, then this is
## specified directly by [member action].
var monstercross: bool = false


## If [code]true[/code], enemies can walk into this line intentionally
## in order to activate its [member action].
##
## If the map format does not support action arguments, then this is
## specified directly by [member action].
var monsteruse: bool = false


## If [code]true[/code], this line activates [member action] when
## a projectile explodes against it.
##
## If the map format does not support action arguments, then this is
## specified directly by [member action].
var impact: bool = false


## If [code]true[/code], this line activates [member action] when
## a player is blocked by it.
##
## If the map format does not support action arguments, then this is
## specified directly by [member action].
var playerpush: bool = false


## If [code]true[/code], this line activates [member action] when
## an enemy is blocked by it.
##
## If the map format does not support action arguments, then this is
## specified directly by [member action].
var monsterpush: bool = false


## If [code]true[/code], this line activates [member action] when
## a projectile crosses from one side to the other.
##
## If the map format does not support action arguments, then this is
## specified directly by [member action].
var missilecross: bool = false


## If [code]false[/code], this line's [member action] is set to [code]0[/code]
## after it has been activated. Otherwise, it will be left alone, allowing it
## to be activated more than once.
##
## If the map format does not support action arguments, then this is
## specified directly by [member action].
var repeatspecial: bool = false


## The action ID to run when this Thing is activated.
## Sometimes referred to as "special" by the source code.
##
## How a line is activated varies depending on the map format.
## If it supports action arguments, then it is specified by several flags.
## Otherwise, it depends on what the action is.
var action: int = 0


## [member action]'s integer argument 0.
##
## If the map format does not support action arguments,
## then this may be replaced with a copy of [member tag].
var arg0: int = 0


## [member action]'s integer argument 1.
var arg1: int = 0


## [member action]'s integer argument 2.
var arg2: int = 0


## [member action]'s integer argument 3.
var arg3: int = 0


## [member action]'s integer argument 4.
var arg4: int = 0


## The front [DoomSidedef] of this line.
## Should always be defined.
var side_front: DoomSidedef = null:
	set(new_side):
		if side_front != null:
			side_front.lines.erase(self)
		if new_side != null:
			new_side.lines.append(self)
		side_front = new_side


## The back [DoomSidedef] of this line.
## Is allowed to be [code]null[/code] if [member twosided] is [code]false[/code].
var side_back: DoomSidedef = null:
	set(new_side):
		if side_back != null:
			side_back.lines.erase(self)
		if new_side != null:
			new_side.lines.append(self)
		side_back = new_side


func _entity_identifier() -> StringName:
	return &"linedef"


func _entity_fields() -> Dictionary[StringName, EntityField]:
	return {
		&"id": EntityField.new(^':tag', -1),
		&"v1": EntityField.new(^':v1', null, DoomVertex),
		&"v2": EntityField.new(^':v2', null, DoomVertex),
		&"blocking": EntityField.new(^':blocking', false),
		&"blockmonsters": EntityField.new(^':blockmonsters', false),
		&"twosided": EntityField.new(^':twosided', false),
		&"dontpegtop": EntityField.new(^':dontpegtop', false),
		&"dontpegbottom": EntityField.new(^':dontpegbottom', false),
		&"secret": EntityField.new(^':secret', false),
		&"blocksound": EntityField.new(^':blocksound', false),
		&"dontdraw": EntityField.new(^':dontdraw', false),
		&"mapped": EntityField.new(^':mapped', false),
		&"passuse": EntityField.new(^':passuse', false),
		&"translucent": EntityField.new(^':translucent', false),
		&"jumpover": EntityField.new(^':jumpover', false),
		&"blockfloaters": EntityField.new(^':blockfloaters', false),
		&"playercross": EntityField.new(^':playercross', false),
		&"playeruse": EntityField.new(^':playeruse', false),
		&"monstercross": EntityField.new(^':monstercross', false),
		&"monsteruse": EntityField.new(^':monsteruse', false),
		&"impact": EntityField.new(^':impact', false),
		&"playerpush": EntityField.new(^':playerpush', false),
		&"monsterpush": EntityField.new(^':monsterpush', false),
		&"missilecross": EntityField.new(^':missilecross', false),
		&"repeatspecial": EntityField.new(^':repeatspecial', false),
		&"special": EntityField.new(^':action', 0),
		&"arg0": EntityField.new(^':arg0', 0),
		&"arg1": EntityField.new(^':arg1', 0),
		&"arg2": EntityField.new(^':arg2', 0),
		&"arg3": EntityField.new(^':arg3', 0),
		&"arg4": EntityField.new(^':arg4', 0),
		&"sidefront": EntityField.new(^':side_front', null, DoomSidedef),
		&"sideback": EntityField.new(^':side_back', -1, DoomSidedef),
		&"comment": EntityField.new(^':comment', ''),
	}

const DISPLAY_SCENE := preload("res://linedef_2d.tscn")
var display: DoomLinedef2D = null


func update_display() -> void:
	if display == null:
		display = DISPLAY_SCENE.instantiate()
		display.entity = self
		add_child(display)

	display.update_properties()


func _init(this_map: DoomMap, data: Dictionary) -> void:
	super(this_map, data)
	update_display()
