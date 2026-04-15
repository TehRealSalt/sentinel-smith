class_name MainUI
extends Control

const MAP_TAB_SCENE := preload("res://map_container.tscn")
const MAP_OUTPUT_SCENE := preload("res://output_window.tscn")

@onready var map_tabs := (%MapTabContainer as TabContainer)
@onready var file_dropdown := (%FileButton as MainDropdownFile)

func _ready() -> void:
	MapFileDialog.map_opened.connect(_on_map_ready)
	file_dropdown.request_output.connect(_on_request_output)


func _on_map_ready(file_name: String, map: DoomMap) -> void:
	var map_tab := MAP_TAB_SCENE.instantiate() as MapContainer
	map_tabs.add_child(map_tab)

	map_tab.map = map

	var tab_index: int = map_tabs.get_tab_count() - 1
	var tab_title := ':'.join([file_name, map.map_name])
	map_tabs.set_tab_title(tab_index, tab_title)
	map_tabs.set_current_tab(tab_index)


func _on_request_output() -> void:
	var selected_tab := map_tabs.get_current_tab_control() as MapContainer
	if not selected_tab:
		return

	var map: DoomMap = selected_tab.map
	if not map:
		return

	var win := MAP_OUTPUT_SCENE.instantiate() as Window
	var label := win.get_node('%Text') as RichTextLabel
	label.text = str(map)

	var tab_title: String = map_tabs.get_tab_title(map_tabs.current_tab)
	win.title = ' - '.join([tab_title, win.title])
	add_child(win)
