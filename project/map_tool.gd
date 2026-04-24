class_name MapTool
extends Button


signal ask_tool_change(new_tool: MapTool)


## Pointer to the [MapContainer] that this tool is for.
var container: MapContainer = null


## Which selection mode this tool is for.
## Check this using [method supports_mode].
var mode_filters: Array[MapSelection.Mode] = []


## Returns if the tool supports a specific selection mode.
func supports_mode(mode: MapSelection.Mode) -> bool:
	if mode_filters.is_empty():
		# Assume supporting all modes by default
		return true

	return mode_filters.has(mode)


func _toggled(toggled_on: bool) -> void:
	if toggled_on:
		ask_tool_change.emit(self)


func gui_2d(_view: MapView2D, _ev: InputEvent) -> void:
	pass


func draw_2d(_layer: MapView2DLayer) -> void:
	pass
