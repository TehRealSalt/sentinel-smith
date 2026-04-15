class_name DoomVertex
extends DoomDragHandle
## Represents a vertex as it is in the UDMF specification.


## All [DoomLinedef]s that reference this vertex.
##
## This should [b]not[/b] be modified directly.
## Changing [member DoomLinedef.v1] or [member DoomLinedef.v2]
## will automatically handle updating this list on all
## involved vertices to be accurate.
var lines: Array[DoomLinedef] = []


func _entity_identifier() -> StringName:
	return &"vertex"


func _entity_fields() -> Dictionary[StringName, EntityField]:
	return {
		&"x": EntityField.new(^':position:x', null),
		&"y": EntityField.new(^':position:y', null),
	}
