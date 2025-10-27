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


var potential_hover: Array[DoomSelectable2D] = []


var hover_elem: DoomSelectable2D = null:
	set(new_elem):
		if new_elem != hover_elem:
			if hover_elem:
				hover_elem.highlighted = false
			if new_elem:
				new_elem.highlighted = true

		hover_elem = new_elem


func update_hover_elem() -> void:
	if potential_hover.is_empty():
		hover_elem = null
	else:
		potential_hover.sort_custom(
			func(a: DoomSelectable2D, b: DoomSelectable2D) -> bool:
				var a_dist: float = a.position.distance_to(a.get_global_mouse_position())
				var b_dist: float = b.position.distance_to(b.get_global_mouse_position())
				return a_dist < b_dist
		)
		hover_elem = potential_hover[0]


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		update_hover_elem()


func _on_selectable_2d_enter(obj: DoomSelectable2D) -> void:
	if obj.entity.map != map:
		return

	if obj.get_script() != select_filter:
		return

	if not potential_hover.has(obj):
		potential_hover.push_back(obj)

	update_hover_elem()


func _on_selectable_2d_exit(obj: DoomSelectable2D) -> void:
	if obj.entity.map != map:
		return

	if obj.get_script() != select_filter:
		return

	while potential_hover.has(obj):
		potential_hover.erase(obj)

	update_hover_elem()


# TODO: may want to make sure this is init without
# needing it to precisely line up with the scene layout
var select_filter: Script = DoomVertex2D:
	set(new_filter):
		if select_filter != new_filter:
			potential_hover.clear()
			update_hover_elem()

		select_filter = new_filter


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


func _ready() -> void:
	EventBus.selectable_2d_entered.connect(_on_selectable_2d_enter)
	EventBus.selectable_2d_exited.connect(_on_selectable_2d_exit)
