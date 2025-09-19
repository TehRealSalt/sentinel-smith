class_name MapViewport
extends SubViewport


const ZOOM_LEVELS: Array[float] = [
	0.125, 0.25, 0.5, 0.75, 1.0,
	1.25, 1.5, 1.75, 2.0,
	2.5, 3.0, 3.5, 4.0
]

const DEFAULT_ZOOM := 1

var zoom_level: int = DEFAULT_ZOOM:
	set(v):
		zoom_level = clampi(v, 0, ZOOM_LEVELS.size() - 1)

		var camera := get_camera_2d()
		var zoom := ZOOM_LEVELS[zoom_level] * 0.25 # 0.25 is possibly temp
		camera.zoom = Vector2(zoom, -zoom) # Doom Y coordinate is flipped


func mouse_zoom(zoom_offset: int = 0) -> void:
	var camera := get_camera_2d()
	var prev_pos := camera.get_local_mouse_position()

	zoom_level += zoom_offset

	var new_pos := camera.get_local_mouse_position()
	camera.translate(prev_pos - new_pos)


func _unhandled_input(ev: InputEvent) -> void:
	var button := (ev as InputEventMouseButton)
	if button == null:
		return

	match button.button_index:
		MouseButton.MOUSE_BUTTON_WHEEL_UP:
			if button.pressed:
				mouse_zoom(1)
		MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
			if button.pressed:
				mouse_zoom(-1)


func _ready() -> void:
	zoom_level = DEFAULT_ZOOM
