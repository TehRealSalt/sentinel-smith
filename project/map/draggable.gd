@abstract
class_name DoomDragHandle
extends DoomEntity
## A map element that can be dragged in 2D space.


## This entity's 2D position.
var position: Vector2


func get_drag_handles() -> Array[DoomDragHandle]:
	# We ARE the draggable.
	return [self]
