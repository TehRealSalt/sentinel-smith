class_name MainUI extends Control

const MAP_TAB_SCENE := preload("res://map_control.tscn")
const MAP_OUTPUT_SCENE := preload("res://output_window.tscn")

@onready var map_tabs := (%MapTabContainer as TabContainer)


func _ready() -> void:
	EventBus.map_ready.connect(_on_map_ready)
	EventBus.request_output.connect(_on_request_output)


func _on_map_ready(file_name: String, map: DoomMap) -> void:
	var tab := MAP_TAB_SCENE.instantiate() as DoomMapControl

	map_tabs.add_child(tab)

	var tab_title := ':'.join([file_name, map.map_name])
	map_tabs.set_tab_title(map_tabs.get_tab_count() - 1, tab_title)

	tab.map = map


func _on_request_output() -> void:
	var selected_tab := map_tabs.get_current_tab_control() as DoomMapControl
	if not selected_tab:
		return

	var map: DoomMap = selected_tab.map
	if not map:
		return

	var win := MAP_OUTPUT_SCENE.instantiate() as MapOutputWindow

	var tab_title: String = map_tabs.get_tab_title(map_tabs.current_tab)
	win.title = ' - '.join([tab_title, win.title])

	PerfTiming.start(&'DoomMap.output')
	win.output_string = str(map)
	PerfTiming.stop(&'DoomMap.output')

	add_child(win)
