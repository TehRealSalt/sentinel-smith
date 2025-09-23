class_name DoomMapControl
extends Control

@onready var view := %Viewport as SubViewport

var map: DoomMap = null:
	set(new_map):
		if map != null:
			map.queue_free()

		if new_map != null:
			view.add_child(new_map)

		map = new_map


# TODO: may want to make sure this is init without
# needing it to precisely line up with the scene layout
var select_filter: Script = DoomVertex2D


var selected: Array[DoomSelectable2D] = []


func _on_selectable_2d_clicked(obj: DoomSelectable2D) -> void:
	if obj.entity.map != map:
		return

	if not obj.get_script() == select_filter:
		return

	var index := selected.find(obj)
	if index != -1:
		selected.remove_at(index)
		obj.highlighted = false
	else:
		selected.push_back(obj)
		obj.highlighted = true


func _ready() -> void:
	EventBus.selectable_2d_clicked.connect(_on_selectable_2d_clicked)


func _on_vertices_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		select_filter = DoomVertex2D


func _on_lines_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		select_filter = DoomLinedef2D


func _on_sectors_button_toggled(_toggled_on: bool) -> void:
	#if toggled_on:
		#select_filter = DoomSector2D
	pass
