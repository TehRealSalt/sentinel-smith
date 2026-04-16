class_name MapContainer
extends Control
## A tab for which contains the [DoomMap] and all of the methods
## to inspect and interact with its data.


@onready var _view_2d: MapView2D = %MapView2D


## Emits when grid size is changed for this map.
signal grid_size_changed(new_grid: float)


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
		grid_size_changed.emit(grid_size)


## Returns a [Vector2] snapped to the grid.
func grid_snapped_vec(input: Vector2) -> Vector2:
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
		else:
			if key.keycode == KEY_BRACKETLEFT:
				grid_size *= 0.5
			elif key.keycode == KEY_BRACKETRIGHT:
				grid_size *= 2.0


func _ready() -> void:
	_view_2d.container = self
