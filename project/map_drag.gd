class_name MapDrag
extends RefCounted

## Pointer to the [MapContainer] that this drag is for.
var container: MapContainer = null


## The [Control] node that is handling the drag.
var active: Control = null


## The position of the mouse at the start of the drag,
## in world space.
var anchor_pos: Vector2 = Vector2.ZERO


## A list of all [DoomDragHandle] entities, which should
## be moved with the drag.
var handles: Array[DoomDragHandle] = []


## The original position of every [DoomDragHandle] before
## the movement.
var handle_origins: Dictionary[DoomDragHandle, Vector2] = {}


func _init(p_container: MapContainer) -> void:
	container = p_container


## Resets to the default state.
func unset() -> void:
	active = null
	anchor_pos = Vector2.ZERO
	handles.clear()
	handle_origins.clear()


## Starts dragging the current selection.
func start(control: Control, world_pos: Vector2) -> void:
	if active:
		return

	unset()

	if container.selection.empty():
		return

	active = control
	anchor_pos = world_pos

	for ent: DoomEntity in container.selection.entities:
		var ent_handles := ent.get_drag_handles()
		for ent_handle: DoomDragHandle in ent_handles:
			if not ent_handle in handles:
				handles.push_back(ent_handle)

	for handle: DoomDragHandle in handles:
		handle_origins[handle] = handle.position


## Updates all of the drag handles' positions, when
## given the current mouse position in world space.
func update(world_pos: Vector2) -> void:
	if not active:
		return

	var raw_delta: Vector2 = world_pos - anchor_pos

	var best_offset: Vector2 = Vector2(INF, INF)
	var best_dist: float = INF
	for handle: DoomDragHandle in handles:
		var raw_pos: Vector2 = handle_origins[handle] + raw_delta
		var snap_pos: Vector2 = container.grid_snapped_vec(raw_pos)

		var snap_offset: Vector2 = snap_pos - raw_pos
		var snap_dist: float = snap_offset.length_squared()
		if snap_dist < best_dist:
			best_offset = snap_offset
			best_dist = snap_dist

	var snapped_delta: Vector2 = raw_delta + best_offset
	for handle: DoomDragHandle in handles:
		handle.position = handle_origins[handle] + snapped_delta


## Finalizes the drag movement and creates an Undo/Redo action for it.
func stop() -> void:
	if not active:
		return

	container.undo_redo.create_action('Drag selection')
	for handle: DoomDragHandle in handles:
		container.undo_redo.add_do_property(handle, &'position', handle.position)
		container.undo_redo.add_undo_property(handle, &'position', handle_origins[handle])
	container.undo_redo.commit_action()

	unset()
