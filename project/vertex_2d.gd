class_name DoomVertex2D
extends Area2D

const VERTEX_BOX_SIZE := 10.0

## Update our properties from a [DoomVertex].
func update(vertex: DoomVertex) -> void:
	global_position = vertex.vector()
	queue_redraw()


func _draw() -> void:
	var rect_size := Vector2(VERTEX_BOX_SIZE, VERTEX_BOX_SIZE)
	draw_rect(
		Rect2(-rect_size, rect_size * 2.0),
		Color.CORNFLOWER_BLUE
	)
