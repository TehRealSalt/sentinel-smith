@abstract
class_name DoomDragHandle
extends DoomEntity
## A map element that can be dragged in 2D space.


## This entity's 2D position.
var position: Vector2:
	set(v):
		position = v
		_moved()


## Called when the [DoomDragHandle] has been moved.
func _moved() -> void:
	pass


func get_drag_handles() -> Array[DoomDragHandle]:
	# We ARE the draggable.
	return [self]


## Returns an array of entities that moving this entity would also affect.
## This is needed for drawing entities in static / dynamic layers.
func get_dependants() -> Array[DoomEntity]:
	# By default, no dependants.
	return []
