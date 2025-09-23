@abstract class_name DoomSelectable2D extends Area2D
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


func _on_input_event(view: Viewport, ev: InputEvent, _shape_idx: int) -> void:
	var button := (ev as InputEventMouseButton)
	if button == null:
		return

	if button.button_index == MOUSE_BUTTON_LEFT and button.pressed:
		EventBus.selectable_2d_clicked.emit(self)
		view.set_input_as_handled()
		return
