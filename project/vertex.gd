class_name DoomVertex
extends DoomEntity
## Represents a vertex as it is in the UDMF specification.


func _entity_identifier() -> StringName:
	return &"vertex"


func _entity_fields() -> Dictionary[StringName, EntityField]:
	return {
		&"x": EntityField.new(TYPE_FLOAT, null),
		&"y": EntityField.new(TYPE_FLOAT, null),
	}


func vector() -> Vector2:
	var x: float = get(&"x")
	var y: float = get(&"y")
	return Vector2(x, y)
