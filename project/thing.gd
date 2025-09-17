class_name DoomThing
extends DoomEntity
## Represents a "thing" as it is in the UDMF specification.
## These are objects that are defined per configuration.


## This Thing's tag. Sometimes referred to by the UDMF spec as "ID".
var tag: int = 0


## This Thing's 2D position.
var position: Vector2


## This Thing's Z offset, relative to the sector's floor or ceiling height.
var height: float = 0.0


## This Thing's facing yaw. 0 faces east.
var angle: int = 0


## This Thing's type ID. Sometimes referred to as a "DoomEdNum".
var type: int


## If set to [code]true[/code], this Thing is spawned on difficulty 1.
## In Doom, this is "I'm too young to die", or "baby" interally.
## In Snap, this corresponds to "Easy" and "Normal".
var skill1: bool = false


## If set to [code]true[/code], this Thing is spawned on difficulty 2.
## In Doom, this is "Hey, not too rough", or "easy" interally.
## In Snap, this corresponds to "Hard" and "Very Rude".
var skill2: bool = false


## If set to [code]true[/code], this Thing is spawned on difficulty 3.
## In Doom, this is "Hurt me plenty", or "medium" interally.
var skill3: bool = false


## If set to [code]true[/code], this Thing is spawned on difficulty 4.
## In Doom, this is "Ultra-Violence", or "hard" interally.
var skill4: bool = false


## If set to [code]true[/code], this Thing is spawned on difficulty 5.
## In Doom, this corresponds to "Nightmare!".
var skill5: bool = false


## If set to [code]true[/code], enemies will try to "ambush" the player.
## This means that, if they hear the player, they won't immediately start
## moving around; instead, they will be able to see all around themselves.
var ambush: bool = false


## If set to [code]true[/code], this Thing is spawned in single-player mode.
var single: bool = false


## If set to [code]true[/code], this Thing is spawned in deathmatch mode.
var dm: bool = false


## If set to [code]true[/code], this Thing is spawned in co-operative mode.
var coop: bool = false


## If set to [code]true[/code], this enemy is an MBF-style "friendly" enemy.
## Compared to [member strifeally], these follow the player, occasionally
## can attack other friendly enemies, and have lots of extra AI.
##
## This is an Doom/MBF flag; behavior is undefined for Heretic/Hexen/Strife.
var friend: bool = false


## If set to [code]true[/code], this enemy needs to be activated via actions
## before it can be damaged or move around.
##
## This is a Hexen flag; behavior is undefined for Doom/Heretic/Strife.
var dormant: bool = false


## If set to [code]true[/code], this Thing spawns for player class 1.
## In Hexen, this corresponds to playing a Fighter.
##
## This is a Hexen flag; behavior is undefined for Doom/Heretic/Strife.
var class1: bool = false


## If set to [code]true[/code], this Thing spawns for player class 2.
## In Hexen, this corresponds to playing a Cleric.
##
## This is a Hexen flag; behavior is undefined for Doom/Heretic/Strife.
var class2: bool = false


## If set to [code]true[/code], this Thing spawns for player class 3.
## In Hexen, this corresponds to playing a Mage.
##
## This is a Hexen flag; behavior is undefined for Doom/Heretic/Strife.
var class3: bool = false


## If set to [code]true[/code], this enemy doesn't move around.
##
## This is a Strife flag; behavior is undefined for Doom/Heretic/Hexen.
var standing: bool = false


## If set to [code]true[/code], this enemy is a Strife-style "ally".
## Compared to [member friend], these wander around aimlessly, never attack
## other allies, and try to attack the same target as the player.
##
## This is a Strife flag; behavior is undefined for Doom/Heretic/Hexen.
var strifeally: bool = false


## If set to [code]true[/code], this Thing is 25% translucent.
## If combined with [member invisible], it becomes 75% translucent instead.
##
## This is a Strife flag; behavior is undefined for Doom/Heretic/Hexen.
var translucent: bool = false


## If set to [code]true[/code], this Thing is completely invisible.
## If combined with [member translucent], it becomes 75% translucent instead.
##
## This is a Strife flag; behavior is undefined for Doom/Heretic/Hexen.
var invisible: bool = false


## The action ID to run when this Thing is activated.
## Sometimes referred to as "special" by the source code.
## How a Thing is activated depends on its [member type].
##
## This is from Hexen; behavior is undefined for Doom/Heretic/Hexen.
var action: int = 0


## [member action]'s integer argument 0.
##
## This is from Hexen; behavior is undefined for Doom/Heretic/Hexen.
var arg0: int = 0


## [member action]'s integer argument 1.
##
## This is from Hexen; behavior is undefined for Doom/Heretic/Hexen.
var arg1: int = 0


## [member action]'s integer argument 2.
##
## This is from Hexen; behavior is undefined for Doom/Heretic/Hexen.
var arg2: int = 0


## [member action]'s integer argument 3.
##
## This is from Hexen; behavior is undefined for Doom/Heretic/Hexen.
var arg3: int = 0


## [member action]'s integer argument 4.
##
## This is from Hexen; behavior is undefined for Doom/Heretic/Hexen.
var arg4: int = 0


func _entity_identifier() -> StringName:
	return &"thing"


func _entity_fields() -> Dictionary[StringName, EntityField]:
	return {
		&"id": EntityField.new(^':tag', 0),
		&"x": EntityField.new(^':position:x', null),
		&"y": EntityField.new(^':position:y', null),
		&"height": EntityField.new(^':height', 0.0),
		&"angle": EntityField.new(^':angle', 0),
		&"type": EntityField.new(^':type', null),
		&"skill1": EntityField.new(^':skill1', false),
		&"skill2": EntityField.new(^':skill2', false),
		&"skill3": EntityField.new(^':skill3', false),
		&"skill4": EntityField.new(^':skill4', false),
		&"skill5": EntityField.new(^':skill5', false),
		&"ambush": EntityField.new(^':ambush', false),
		&"single": EntityField.new(^':single', false),
		&"dm": EntityField.new(^':dm', false),
		&"coop": EntityField.new(^':coop', false),
		&"friend": EntityField.new(^':friend', false),
		&"dormant": EntityField.new(^':dormant', false),
		&"class1": EntityField.new(^':class1', false),
		&"class2": EntityField.new(^':class2', false),
		&"class3": EntityField.new(^':class3', false),
		&"standing": EntityField.new(^':standing', false),
		&"strifeally": EntityField.new(^':strifeally', false),
		&"translucent": EntityField.new(^':translucent', false),
		&"invisible": EntityField.new(^':invisible', false),
		&"action": EntityField.new(^':action', 0),
		&"arg0": EntityField.new(^':arg0', 0),
		&"arg1": EntityField.new(^':arg1', 0),
		&"arg2": EntityField.new(^':arg2', 0),
		&"arg3": EntityField.new(^':arg3', 0),
		&"arg4": EntityField.new(^':arg4', 0),
		&"comment": EntityField.new(^':comment', ''),
	}
