class_name DoomLinedef2D
extends DoomSelectable2D
## Represents a selectable vertex in 2D mode. 


## Line width when rendered.
const LINE_WIDTH := 8.0


## Line width of the facing normal notch.
const NORMAL_NOTCH_WIDTH := LINE_WIDTH * 0.5


## Size of the facing normal notch.
const NORMAL_NOTCH_LENGTH := LINE_WIDTH * 1.5


## The first vertex.
var v1: DoomVertex2D


## The second vertex.
var v2: DoomVertex2D


## Global coordinate of the center point.
var mid := Vector2.ZERO


## The line's normal facing normal. This comes from the front side.
var normal := Vector2.ZERO


## Update our properties from a [DoomLinedef].
func _on_entity_update() -> void:
	var line := entity as DoomLinedef

	v1 = line.v1.display
	v2 = line.v2.display

	global_position = (v1.global_position + v2.global_position) * 0.5

	var delta := v1.global_position - v2.global_position
	normal = delta.normalized()
	normal = normal.rotated(deg_to_rad(90.0))

	var collider := (%Collider as CollisionShape2D)
	collider.rotation = normal.angle()

	var shape := (collider.shape as RectangleShape2D)
	shape.size = Vector2(
		NORMAL_NOTCH_LENGTH * 3.0,
		delta.length()
	)


func _draw() -> void:
	var col := Color.LIGHT_GRAY

	if highlighted:
		col = Color.CORAL

	draw_line(
		Vector2.ZERO,
		Vector2.ZERO + (normal * NORMAL_NOTCH_LENGTH),
		col,
		NORMAL_NOTCH_WIDTH
	)
	draw_line(
		global_position - v1.global_position,
		global_position - v2.global_position,
		col,
		LINE_WIDTH
	)
