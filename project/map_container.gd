class_name MapContainer
extends Control
## A tab for which contains the [DoomMap] and all of the methods
## to inspect and interact with its data.


@onready var _view_2d: MapView2D = %MapView2D
@onready var _tools: Control = %Tools

## Emits when grid settings are changed for this map.
signal grid_changed()


## The map that this container represents.
var map: DoomMap = null


## Our undo/redo state.
var undo_redo := UndoRedo.new()


## Our selection state.
var selection := MapSelection.new(self)


## Our drag state.
var drag := MapDrag.new(self)


## This tab's editing grid size.
var grid_size: float = 64.0:
	set(v):
		grid_size = v
		grid_changed.emit()


## If grid snapping is enabled.
var grid_snap_enabled: bool = true:
	set(v):
		grid_snap_enabled = v
		grid_changed.emit()


## If we want views to display the grid.
var grid_visible: bool = true:
	set(v):
		grid_visible = v
		grid_changed.emit()


## Returns a [Vector2] snapped to the grid.
## If grid snap is off, returns the input, unchanged.
func grid_snapped_vec(input: Vector2) -> Vector2:
	if not grid_snap_enabled:
		return input

	return Vector2(
		roundf(input.x / grid_size) * grid_size,
		roundf(input.y / grid_size) * grid_size
	)


func _unhandled_input(ev: InputEvent) -> void:
	var key := ev as InputEventKey
	if key and key.pressed:
		if key.ctrl_pressed:
			if key.keycode == KEY_Z:
				undo_redo.undo()
				_view_2d.force_refresh()
			elif key.keycode == KEY_Y:
				undo_redo.redo()
				_view_2d.force_refresh()
			elif key.keycode == KEY_G:
				grid_snap_enabled = not grid_snap_enabled
		elif key.shift_pressed:
			if key.keycode == KEY_BRACKETLEFT:
				grid_size *= 0.25
			elif key.keycode == KEY_BRACKETRIGHT:
				grid_size *= 4.0
			elif key.keycode == KEY_G:
				grid_visible = not grid_visible
		else:
			if key.keycode == KEY_BRACKETLEFT:
				grid_size *= 0.5
			elif key.keycode == KEY_BRACKETRIGHT:
				grid_size *= 2.0


func _on_mode_change() -> void:
	pass # TODO: make only relevant tools visible


func _ready_buttons() -> void:
	var first_mode: SelectionModeButton = null
	var modes_group: ButtonGroup = ButtonGroup.new()

	for tool: Control in _tools.get_children():
		var mode_button := tool as SelectionModeButton
		if mode_button:
			mode_button.button_group = modes_group
			mode_button.ask_mode_change.connect(selection.change_mode)

			if not first_mode:
				first_mode = mode_button

	assert(first_mode)
	first_mode.set_pressed(true)


func _ready() -> void:
	_view_2d.container = self
	selection.mode_changed.connect(_on_mode_change)
	_ready_buttons()
