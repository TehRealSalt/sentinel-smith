extends MenuButton


enum ItemID
{
	OPEN,
	SAVE,
	OUTPUT,
	_MAX
}


func item_pressed(id: int) -> void:
	match id:
		ItemID.OPEN:
			open_map_dialog()
		ItemID.OUTPUT:
			create_map_output()
		_:
			assert(false, 'Undefined item ID %d in FileButton' % id)


func open_map_dialog() -> void:
	pass


func create_map_output() -> void:
	pass


func _ready() -> void:
	var popup := get_popup()
	popup.add_item('Open', ItemID.OPEN, (KEY_MASK_CTRL | KEY_O) as Key)
	popup.add_item('Save', ItemID.SAVE, (KEY_MASK_CTRL | KEY_S) as Key)
	popup.set_item_disabled(ItemID.SAVE, true)
	popup.add_item('DEBUG: Show Output', ItemID.OUTPUT)
