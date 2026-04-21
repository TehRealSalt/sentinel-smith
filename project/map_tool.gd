class_name MapTool
extends Button


signal ask_tool_change(new_tool: MapTool)


## Pointer to the [MapContainer] that this tool is for.
var container: MapContainer = null


## Which selection mode this tool is for.
var mode_filter: MapSelection.Mode = MapSelection.Mode.ANY


func _toggled(toggled_on: bool) -> void:
	if toggled_on:
		ask_tool_change.emit(self)


func gui_2d(_view: MapView2D, _ev: InputEvent) -> void:
	pass


func draw_2d(_layer: MapView2DLayer) -> void:
	pass
