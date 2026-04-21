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


## The [ButtonGroup] for ALL mode buttons.
var mode_group: ButtonGroup = ButtonGroup.new()


## The [ButtonGroup] for ALL tool buttons.
var tool_group: ButtonGroup = ButtonGroup.new()


## The [MapTool] to default to when changing modes.
var default_tool: MapTool = null


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


## Gets the currently selected tool.
func get_tool() -> MapTool:
	var btn: Button = tool_group.get_pressed_button()
	return btn as MapTool


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


func _on_mode_change(mode: MapSelection.Mode) -> void:
	for btn: Button in tool_group.get_buttons():
		var tool := btn as MapTool
		if tool.mode_filter != MapSelection.Mode.ANY:
			tool.visible = (tool.mode_filter == mode)

	var cur_tool: MapTool = get_tool()
	if cur_tool:
		if not cur_tool.visible:
			default_tool.set_pressed(true)


func _on_tool_change(tool: MapTool) -> void:
	if tool.mode_filter != MapSelection.Mode.ANY:
		# ensure correct mode
		var mode_set: bool = false
		for btn: Button in mode_group.get_buttons():
			var mode_btn := btn as MapSelectionModeButton
			if mode_btn.type == tool.mode_filter:
				mode_btn.set_pressed(true)
				mode_set = true
				break
		assert(mode_set)


func _ready_buttons() -> void:
	var default_mode: MapSelectionModeButton = null
	default_tool = null

	for tool_node: Node in _tools.get_children():
		var mode_button := tool_node as MapSelectionModeButton
		if mode_button:
			mode_button.button_group = mode_group
			mode_button.ask_mode_change.connect(selection.change_mode)

			if not default_mode:
				default_mode = mode_button

		var tool := tool_node as MapTool
		if tool:
			tool.container = self
			tool.button_group = tool_group
			tool.ask_tool_change.connect(_on_tool_change)

			if not default_tool:
				default_tool = tool

	assert(default_mode)
	default_mode.set_pressed(true)

	assert(default_tool)
	assert(default_tool.mode_filter == MapSelection.Mode.ANY)
	default_tool.set_pressed(true)


func _ready() -> void:
	_view_2d.container = self
	selection.mode_changed.connect(_on_mode_change)
	_ready_buttons()
