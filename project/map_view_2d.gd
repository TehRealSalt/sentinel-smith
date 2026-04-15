class_name MapView2D
extends Control
## Handles the 2D display and interaction with a [MapContainer].


## The number of pixels, in screen-space, that we are allowed
## to select entities from.
const PICK_THRESHOLD_SCREEN: float = 8.0


@onready var _static: MapView2DStatic = %Static
@onready var _dynamic: MapView2DDynamic = %Dynamic


## Pointer to the [MapContainer] that we are viewing.
var container: MapContainer = null:
	set(v):
		container = v
		_static.container = container
		_dynamic.container = container


## Current view transform.
var transform := Transform2D():
	set(v):
		transform = v
		_static.transform = transform
		_dynamic.transform = transform


var _view_drag: bool = false
var _view_drag_pos: Vector2 = Vector2.ZERO


func _gui_zoom(ev: InputEvent) -> void:
	var mouse_btn := ev as InputEventMouseButton
	if mouse_btn and mouse_btn.pressed:
		match mouse_btn.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				transform = transform.scaled(Vector2(1.1, 1.1))
			MOUSE_BUTTON_WHEEL_DOWN:
				var inverted: float = 1.0 / 1.1
				transform = transform.scaled(Vector2(inverted, inverted))


func _gui_view_drag(ev: InputEvent) -> void:
	var mouse_btn := ev as InputEventMouseButton
	if mouse_btn and mouse_btn.button_index == MOUSE_BUTTON_RIGHT:
		_view_drag = mouse_btn.pressed
		_view_drag_pos = mouse_btn.position

	if _view_drag:
		var motion := ev as InputEventMouseMotion
		if motion:
			transform = transform.translated(motion.position - _view_drag_pos)
			_view_drag_pos = motion.position


func _pick_vertex(world_pos: Vector2, threshold_sqr: float) -> DoomVertex:
	var best: DoomVertex = null
	var best_dist: float = INF

	for vertex in container.map.vertices:
		var dist: float = vertex.position.distance_squared_to(world_pos)
		if dist < threshold_sqr and dist < best_dist:
			best = vertex
			best_dist = dist

	return best


func _pick_line(world_pos: Vector2, threshold_sqr: float) -> DoomLinedef:
	var best: DoomLinedef = null
	var best_dist: float = INF

	for line in container.map.lines:
		var p: Vector2 = Geometry2D.get_closest_point_to_segment(world_pos, line.v1.position, line.v2.position)
		var dist: float = p.distance_squared_to(world_pos)
		if dist < threshold_sqr and dist < best_dist:
			best = line
			best_dist = dist

	return best


func _pick_thing(world_pos: Vector2, threshold_sqr: float) -> DoomThing:
	var best: DoomThing = null
	var best_dist: float = INF

	for thing in container.map.things:
		var dist: float = thing.position.distance_squared_to(world_pos)
		if dist < threshold_sqr and dist < best_dist:
			best = thing
			best_dist = dist

	return best


func _pick(world_pos: Vector2, threshold_sqr: float) -> Array[DoomEntity]:
	var vertex := _pick_vertex(world_pos, threshold_sqr)
	if vertex:
		return [vertex]

	var line := _pick_line(world_pos, threshold_sqr)
	if line:
		return [line]

	var thing := _pick_thing(world_pos, threshold_sqr)
	if thing:
		return [thing]

	return []


func _gui_pick(ev: InputEvent) -> void:
	var mouse_btn := ev as InputEventMouseButton
	if mouse_btn and mouse_btn.button_index == MOUSE_BUTTON_LEFT and mouse_btn.pressed:
		var world_pos: Vector2 = transform.affine_inverse() * mouse_btn.position
		var pick_threshold: float = PICK_THRESHOLD_SCREEN / transform.get_scale().x
		var pick_threshold_sqr: float = pick_threshold * pick_threshold

		var hits: Array[DoomEntity] = _pick(world_pos, pick_threshold_sqr)
		container.selection.update(hits, MapSelection.Modifiers.TOGGLE)

		_static.queue_redraw()
		_dynamic.queue_redraw()


func _gui_input(ev: InputEvent) -> void:
	_gui_zoom(ev)
	_gui_view_drag(ev)
	_gui_pick(ev)


func _ready() -> void:
	# Doom map coordinates have flipped Y
	transform = transform.scaled(Vector2(1.0, -1.0))
