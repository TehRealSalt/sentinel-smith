class_name DoomVertex
extends DoomEntity
## Represents a vertex as it is in the UDMF specification.


## This vertex's 2D position.
var position: Vector2


func _entity_identifier() -> StringName:
	return &"vertex"


func _entity_fields() -> Dictionary[StringName, EntityField]:
	return {
		&"x": EntityField.new(^':position:x', null),
		&"y": EntityField.new(^':position:y', null),
	}


const DISPLAY_SCENE := preload("res://vertex_2d.tscn")
var display: DoomVertex2D = null


func update_display() -> void:
	if display == null:
		display = DISPLAY_SCENE.instantiate()
		add_child(display)

	display.update(self)


func _init(this_map: DoomMap, data: Dictionary) -> void:
	super(this_map, data)
	update_display()
