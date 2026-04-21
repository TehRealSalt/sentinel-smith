class_name MapView2D
extends Control
## Handles the 2D display and interaction with a [MapContainer].


## The number of pixels, in screen-space, that we are allowed
## to select entities from.
const MOUSE_TRESHOLD: float = 6.0


@onready var _grid: MapView2DGrid = %Grid
@onready var _static: MapView2DStatic = %Static
@onready var _dynamic: MapView2DDynamic = %Dynamic


## Pointer to the [MapContainer] that we are viewing.
var container: MapContainer = null:
	set(v):
		container = v
		container.grid_changed.connect(_on_grid_change)
		_grid.container = container
		_static.container = container
		_dynamic.container = container


## Current view transform.
var transform := Transform2D():
	set(v):
		transform = v
		_grid.transform = transform
		_static.transform = transform
		_dynamic.transform = transform


## Tracks if we are trying to do a marquee selection or not.
var marquee_active: bool = false


## The position of the starting corner of the marquee selection,
## in world space.
var marquee_start: Vector2 = Vector2.ZERO


## The position of the final corner of the marquee selection,
## in world space.
var marquee_end: Vector2 = Vector2.ZERO


var _view_drag: bool = false
var _view_drag_pos: Vector2 = Vector2.ZERO


var _drag_pending: bool = false
var _drag_start_pos: Vector2 = Vector2.ZERO


func _on_grid_change() -> void:
	_grid.visible = container.grid_visible
	_grid.queue_redraw()


func force_refresh() -> void:
	_grid.queue_redraw()
	_static.queue_redraw()
	_dynamic.queue_redraw()


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


func _gui_drag(ev: InputEvent) -> void:
	var mb := ev as InputEventMouseButton
	if mb and mb.button_index == MOUSE_BUTTON_LEFT:
		if not mb.pressed:
			container.drag.stop()
			_static.queue_redraw()
			_dynamic.queue_redraw()
			return

	var motion := ev as InputEventMouseMotion
	if motion:
		var world_pos: Vector2 = transform.affine_inverse() * motion.position
		container.drag.update(world_pos)
		_dynamic.queue_redraw()


func _gui_marquee(ev: InputEvent) -> void:
	var mb := ev as InputEventMouseButton
	if mb and mb.button_index == MOUSE_BUTTON_LEFT:
		if not mb.pressed:
			marquee_active = false

			var rect := Rect2(marquee_start, marquee_end - marquee_start).abs()
			var threshold: float = MOUSE_TRESHOLD / transform.get_scale().x
			rect.grow(threshold)

			var hits: Array[DoomEntity] = []
			match container.selection.mode:
				MapSelection.Mode.VERTICES:
					hits.append_array(container.map.pick_vertices_in_rect(rect))
				MapSelection.Mode.LINES:
					hits.append_array(container.map.pick_lines_in_rect(rect))
				MapSelection.Mode.SECTORS:
					hits.append_array(container.map.pick_sectors_in_rect(rect))
				MapSelection.Mode.THINGS:
					hits.append_array(container.map.pick_things_in_rect(rect))

			var mod: MapSelection.Modifiers = MapSelection.Modifiers.REPLACE
			if mb.shift_pressed:
				mod = MapSelection.Modifiers.ADD
			elif mb.ctrl_pressed:
				mod = MapSelection.Modifiers.TOGGLE
			container.selection.update(hits, mod)

			_static.queue_redraw()
			_dynamic.queue_redraw()
			return

	var motion := ev as InputEventMouseMotion
	if motion:
		marquee_end = transform.affine_inverse() * motion.position
		_dynamic.queue_redraw()


func _gui_pick(ev: InputEvent) -> void:
	if container.drag.active == self:
		_gui_drag(ev)
		return

	if marquee_active:
		_gui_marquee(ev)
		return

	var threshold: float = MOUSE_TRESHOLD / transform.get_scale().x
	var threshold_sqr: float = threshold * threshold

	var mb := ev as InputEventMouseButton
	if mb and mb.button_index == MOUSE_BUTTON_LEFT:
		var world_pos: Vector2 = transform.affine_inverse() * mb.position
		if mb.pressed:
			var hit: DoomEntity = null
			match container.selection.mode:
				MapSelection.Mode.VERTICES:
					hit = container.map.pick_vertex(world_pos, threshold_sqr)
				MapSelection.Mode.LINES:
					hit = container.map.pick_line(world_pos, threshold_sqr)
				MapSelection.Mode.SECTORS:
					hit = container.map.pick_sector(world_pos)
				MapSelection.Mode.THINGS:
					hit = container.map.pick_thing(world_pos, threshold_sqr)

			var mod: MapSelection.Modifiers = MapSelection.Modifiers.REPLACE
			if mb.shift_pressed:
				mod = MapSelection.Modifiers.ADD
			elif mb.ctrl_pressed:
				mod = MapSelection.Modifiers.TOGGLE

			var arr: Array[DoomEntity] = []
			if hit:
				arr = [hit]

			container.selection.update(arr, mod)
			_static.queue_redraw()
			_dynamic.queue_redraw()

			if hit == null or container.selection.has_all(arr):
				_drag_pending = true
				_drag_start_pos = world_pos
			else:
				_drag_pending = false
		else:
			_drag_pending = false

	if _drag_pending:
		var motion := ev as InputEventMouseMotion
		if motion:
			var world_pos: Vector2 = transform.affine_inverse() * motion.position
			var delta := world_pos - _drag_start_pos
			if delta.length_squared() > threshold_sqr:
				if container.selection.empty():
					marquee_active = true
					marquee_start = _drag_start_pos
				else:
					container.drag.start(self, _drag_start_pos)
					marquee_active = false
				_drag_pending = false


func _gui_input(ev: InputEvent) -> void:
	_gui_zoom(ev)
	_gui_view_drag(ev)
	_gui_pick(ev)


func _ready() -> void:
	_static.view = self
	_dynamic.view = self

	# Doom map coordinates have flipped Y
	transform = transform.scaled(Vector2(1.0, -1.0))
