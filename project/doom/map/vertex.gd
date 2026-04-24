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


func get_dependants() -> Array[DoomEntity]:
	var ret: Array[DoomEntity] = []

	for line: DoomLinedef in lines:
		ret.push_back(line)

		ret.push_back(line.side_front)
		ret.push_back(line.side_front.sector)

		if line.side_back:
			ret.push_back(line.side_back)
			ret.push_back(line.side_back.sector)

	return ret


func _moved() -> void:
	var deps: Array[DoomEntity] = get_dependants()
	for ent: DoomEntity in deps:
		var sec := ent as DoomSector
		if sec:
			sec.geometry_cache.invalidate()
