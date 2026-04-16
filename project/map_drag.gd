class_name MapDrag
extends RefCounted

## Pointer to the [MapContainer] that this drag is for.
var container: MapContainer = null


## The [Control] node that is handling the drag.
var active: Control = null


var anchor_pos: Vector2 = Vector2.ZERO
var handles: Array[DoomDragHandle] = []
var handle_origins: Dictionary[DoomDragHandle, Vector2] = {}


func _init(p_container: MapContainer) -> void:
	container = p_container


func unset() -> void:
	active = null
	anchor_pos = Vector2.ZERO
	handles.clear()
	handle_origins.clear()


func start(control: Control, world_pos: Vector2) -> void:
	if active:
		return

	unset()

	active = control
	anchor_pos = world_pos

	for ent: DoomEntity in container.selection.entities:
		var ent_handles := ent.get_drag_handles()
		for ent_handle: DoomDragHandle in ent_handles:
			if not ent_handle in handles:
				handles.push_back(ent_handle)

	for handle: DoomDragHandle in handles:
		handle_origins[handle] = handle.position


func update(world_pos: Vector2) -> void:
	if not active:
		return

	var delta: Vector2 = world_pos - anchor_pos
	for handle: DoomDragHandle in handles:
		var new_pos: Vector2 = handle_origins[handle] + delta
		handle.position = container.grid_snapped_vec(new_pos)


func stop() -> void:
	if not active:
		return

	container.undo_redo.create_action('Drag selection')
	for handle: DoomDragHandle in handles:
		container.undo_redo.add_do_property(handle, &'position', handle.position)
		container.undo_redo.add_undo_property(handle, &'position', handle_origins[handle])
	container.undo_redo.commit_action()

	unset()
