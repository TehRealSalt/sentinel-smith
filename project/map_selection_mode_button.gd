class_name MapSelectionModeButton
extends Button

@export var type: MapSelection.Mode


signal ask_mode_change(p_type: MapSelection.Mode)


func _toggled(toggled_on: bool) -> void:
	if toggled_on:
		ask_mode_change.emit(type)
