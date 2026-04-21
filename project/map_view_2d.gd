class_name MapView2D
extends Control
## Handles the 2D display and interaction with a [MapContainer].


@onready var _grid: MapView2DGrid = %Grid
@onready var layer_static: MapView2DStatic = %Static
@onready var layer_dynamic: MapView2DDynamic = %Dynamic


## Pointer to the [MapContainer] that we are viewing.
var container: MapContainer = null:
	set(v):
		container = v
		container.grid_changed.connect(_on_grid_change)
		_grid.container = container
		layer_static.container = container
		layer_dynamic.container = container


## Current view transform.
var transform := Transform2D():
	set(v):
		transform = v
		_grid.transform = transform
		layer_static.transform = transform
		layer_dynamic.transform = transform


var _view_drag: bool = false
var _view_drag_pos: Vector2 = Vector2.ZERO





func _on_grid_change() -> void:
	_grid.visible = container.grid_visible
	_grid.queue_redraw()


func force_refresh() -> void:
	_grid.queue_redraw()
	layer_static.queue_redraw()
	layer_dynamic.queue_redraw()


func _gui_zoom(ev: InputEvent) -> void:
	var mouse_btn := ev as InputEventMouseButton
	if mouse_btn and mouse_btn.pressed:
		match mouse_btn.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				transform = transform.scaled(Vector2(1.1, 1.1))
			MOUSE_BUTTON_WHEEL_DOWN:
				var inverted: float = 1.0 / 1.1
				transform = transform.scaled(Vector2(inverted, inverted))


func _gui_view_drag(ev: InputEvent) -> void:
	var mouse_btn := ev as InputEventMouseButton
	if mouse_btn and mouse_btn.button_index == MOUSE_BUTTON_RIGHT:
		_view_drag = mouse_btn.pressed
		_view_drag_pos = mouse_btn.position

	if _view_drag:
		var motion := ev as InputEventMouseMotion
		if motion:
			transform = transform.translated(motion.position - _view_drag_pos)
			_view_drag_pos = motion.position


func _gui_run_tool(ev: InputEvent) -> void:
	var tool: MapTool = container.get_tool()
	if tool:
		tool.gui_2d(self, ev)


func _gui_input(ev: InputEvent) -> void:
	_gui_zoom(ev)
	_gui_view_drag(ev)
	_gui_run_tool(ev)


func _ready() -> void:
	layer_static.view = self
	layer_dynamic.view = self

	# Doom map coordinates have flipped Y
	transform = transform.scaled(Vector2(1.0, -1.0))
