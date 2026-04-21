extends MapTool


## The number of pixels, in screen-space, that we are allowed
## to select entities from.
const MOUSE_TRESHOLD: float = 6.0


## Tracks if we are trying to do a marquee selection or not.
var marquee_active: bool = false


## The position of the starting corner of the marquee selection,
## in world space.
var marquee_start: Vector2 = Vector2.ZERO


## The position of the final corner of the marquee selection,
## in world space.
var marquee_end: Vector2 = Vector2.ZERO


var drag_pending: bool = false


var drag_start_pos: Vector2 = Vector2.ZERO


func _gui_drag(view: MapView2D, ev: InputEvent) -> void:
	var mb := ev as InputEventMouseButton
	if mb and mb.button_index == MOUSE_BUTTON_LEFT:
		if not mb.pressed:
			container.drag.stop()
			view.layer_static.queue_redraw()
			view.layer_dynamic.queue_redraw()
			return

	var motion := ev as InputEventMouseMotion
	if motion:
		var world_pos: Vector2 = view.transform.affine_inverse() * motion.position
		container.drag.update(world_pos)
		view.layer_dynamic.queue_redraw()


func _gui_marquee(view: MapView2D, ev: InputEvent) -> void:
	var mb := ev as InputEventMouseButton
	if mb and mb.button_index == MOUSE_BUTTON_LEFT:
		if not mb.pressed:
			marquee_active = false

			var rect := Rect2(marquee_start, marquee_end - marquee_start).abs()
			var threshold: float = MOUSE_TRESHOLD / view.transform.get_scale().x
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

			view.layer_static.queue_redraw()
			view.layer_dynamic.queue_redraw()
			return

	var motion := ev as InputEventMouseMotion
	if motion:
		marquee_end = view.transform.affine_inverse() * motion.position
		view.layer_dynamic.queue_redraw()


func gui_2d(view: MapView2D, ev: InputEvent) -> void:
	if container.drag.active == self:
		_gui_drag(view, ev)
		return

	if marquee_active:
		_gui_marquee(view, ev)
		return

	var threshold: float = MOUSE_TRESHOLD / view.transform.get_scale().x
	var threshold_sqr: float = threshold * threshold

	var mb := ev as InputEventMouseButton
	if mb and mb.button_index == MOUSE_BUTTON_LEFT:
		var world_pos: Vector2 = view.transform.affine_inverse() * mb.position
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
			view.layer_static.queue_redraw()
			view.layer_dynamic.queue_redraw()

			if hit == null or container.selection.has_all(arr):
				drag_pending = true
				drag_start_pos = world_pos
			else:
				drag_pending = false
		else:
			drag_pending = false

	if drag_pending:
		var motion := ev as InputEventMouseMotion
		if motion:
			var world_pos: Vector2 = view.transform.affine_inverse() * motion.position
			var delta: Vector2 = world_pos - drag_start_pos
			if delta.length_squared() > threshold_sqr:
				if container.selection.empty():
					marquee_active = true
					marquee_start = drag_start_pos
				else:
					container.drag.start(self, drag_start_pos)
					marquee_active = false
				drag_pending = false


func draw_2d(layer: MapView2DLayer) -> void:
	if marquee_active:
		var rect := Rect2(marquee_start, marquee_end - marquee_start).abs()
		var color := Color.ORANGE
		layer.draw_rect(rect, color, false)

		color.a *= 0.2
		layer.draw_rect(rect, color, true)
