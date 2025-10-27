@abstract
class_name DoomSelectable2D
extends Area2D
## Represents a selectable [DoomEntity] as displayed in 2D mode.
## While [DoomEntity] handles the data of each entity, this class
## handles drawing and interacting with said data.


## The [DoomEntity] that we represent.
var entity: DoomEntity = null


## Set to [code]true[/code] when this has been selected.
var highlighted := false:
	set(v):
		highlighted = v
		queue_redraw()


## Virtual function, ran when [method update_properties] is called.
@abstract func _on_entity_update() -> void


## Updates our properties to match the owning [DoomEntity],
## called after it changes any of its properties.
func update_properties() -> void:
	_on_entity_update()
	queue_redraw()


func _on_mouse_entered() -> void:
	EventBus.selectable_2d_entered.emit(self)


func _on_mouse_exited() -> void:
	EventBus.selectable_2d_exited.emit(self)
