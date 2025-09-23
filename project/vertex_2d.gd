class_name DoomVertex2D
extends DoomSelectable2D
## Represents a selectable vertex in 2D mode. 


const VERTEX_BOX_SIZE := 10.0


func _on_entity_update() -> void:
	var vertex := entity as DoomVertex
	global_position = vertex.position


func _draw() -> void:
	var col := Color.CORNFLOWER_BLUE

	if highlighted:
		col = Color.RED

	var rect_size := Vector2(VERTEX_BOX_SIZE, VERTEX_BOX_SIZE)
	draw_rect(Rect2(-rect_size, rect_size * 2.0), col)
