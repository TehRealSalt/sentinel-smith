class_name MainUI extends Control

const MAP_TAB_SCENE := preload("res://map_container.tscn")
const MAP_OUTPUT_SCENE := preload("res://output_window.tscn")

@onready var map_tabs := (%MapTabContainer as TabContainer)


func _ready() -> void:
	EventBus.map_ready.connect(_on_map_ready)
	EventBus.request_output.connect(_on_request_output)


func _on_map_ready(file_name: String, map: DoomMap) -> void:
	var map_tab := MAP_TAB_SCENE.instantiate() as Node

	var view := map_tab.get_node('%Viewport') as SubViewport
	view.add_child(map)

	map_tabs.add_child(map_tab)

	var tab_title := ':'.join([file_name, map.map_name])
	map_tabs.set_tab_title(map_tabs.get_tab_count() - 1, tab_title)


func _on_request_output() -> void:
	var selected_tab := map_tabs.get_current_tab_control()
	if not selected_tab:
		return

	var view := selected_tab.get_node('%Viewport') as SubViewport
	var map: DoomMap = null
	for child in view.get_children():
		if child is DoomMap:
			map = child
			break

	if not map:
		return

	var win := MAP_OUTPUT_SCENE.instantiate() as Window
	var label := win.get_node('%Text') as RichTextLabel
	label.text = str(map)

	var tab_title: String = map_tabs.get_tab_title(map_tabs.current_tab)
	win.title = ' - '.join([tab_title, win.title])
	add_child(win)
