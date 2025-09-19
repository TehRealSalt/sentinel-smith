@abstract
class_name DoomSelectable2D
extends Area2D
## Represents a selectable [DoomEntity] as displayed in 2D mode.
## While [DoomEntity] handles the data of each entity, this class
## handles drawing and interacting with said data.


## The [DoomEntity] that we represent.
var entity: DoomEntity = null


## Virtual function, ran when [method update_properties] is called.
@abstract
func _on_entity_update() -> void


## Updates our properties to match the owning [DoomEntity],
## called after it changes any of its properties.
func update_properties() -> void:
	_on_entity_update()
	queue_redraw()
