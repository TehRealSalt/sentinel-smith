extends FileDialog


func _on_file_selected(path: String) -> void:
	Input.set_default_cursor_shape(Input.CURSOR_WAIT)

	var file_name := path.get_file()

	var bytes := FileAccess.get_file_as_bytes(path)
	var err := FileAccess.get_open_error()
	if err:
		print("Could not load file '%s': %s" % [path, error_string(err)])
		return

	var wad := WADFile.decode(bytes)
	if wad == null:
		print("Could not load file '%s' as a WAD" % path)
		return

	PerfTiming.start(&'DoomMap.total')
	var map := DoomMap.load_from_wad(wad)
	PerfTiming.stop(&'DoomMap.total')

	if map == null:
		print("Could not load file '%s' as a map" % path)
		return

	EventBus.map_ready.emit(file_name, map)
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
