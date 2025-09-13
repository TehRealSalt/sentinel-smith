extends Control

@onready var open_wad_dialog := (%OpenWADDialog as FileDialog)
@onready var wad_tree := (%WADTree as Tree)
@onready var textmap_display := (%TextMap as RichTextLabel)

var current_wad_name: String = "(null)"
var current_wad: WADFile = null
var current_map: DoomMap = null

func change_wad(wad_file_name: String, wad: WADFile) -> void:
	Input.set_default_cursor_shape(Input.CURSOR_WAIT)
	assert(wad != null)

	if current_map != null:
		current_map.queue_free()
		current_map = null

	current_wad_name = wad_file_name
	current_wad = wad
	update_tree()

	current_map = DoomMap.load_from_wad(current_wad)
	textmap_display.text = str(current_map)

	%SubViewport.add_child(current_map)
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func update_tree() -> void:
	wad_tree.clear()

	if current_wad == null:
		return

	var root := wad_tree.create_item()
	root.set_text(0, current_wad_name)

	for lump in current_wad.lumps:
		var lump_item := wad_tree.create_item(root)
		lump_item.set_text(0, lump.name)

		var lump_size_item := wad_tree.create_item(lump_item)
		lump_size_item.set_text(0, "size: %s" % String.humanize_size(lump.data.size()))


func _on_open_wad_button_pressed() -> void:
	open_wad_dialog.visible = true


func _on_file_dialog_file_selected(path: String) -> void:
	var bytes := FileAccess.get_file_as_bytes(path)
	var err := FileAccess.get_open_error()
	if err:
		print("Could not load file '%s': %s" % [path, error_string(err)])
		return

	var wad := WADFile.decode(bytes)
	if wad == null:
		print("Could not load file '%s' as a WAD" % path)
		return

	change_wad(path.get_file(), wad)
