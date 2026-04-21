class_name MapSelection
extends RefCounted
## Manages selection state for a [MapContainer].


## Emits when the current mode has been changed.
signal mode_changed(type: Mode)


## Different ways of updating the selection state.
## Used for [method update].
enum Modifiers
{
	ADD,
	REMOVE,
	REPLACE,
	TOGGLE,
}


## Each type of [DoomEntity] that can be selected.
enum Mode
{
	ANY,
	VERTICES,
	LINES,
	SECTORS,
	THINGS,
}


## Pointer to the [MapContainer] that this selection applies to.
var container: MapContainer = null


## The currently selected editing mode.
var mode: Mode = Mode.ANY


## All [DoomEntity] references that are considered selected.
var entities: Array[DoomEntity] = []


func _init(p_container: MapContainer) -> void:
	container = p_container


## Changes the current value of [member mode] and
## handles all maintainence needed.
func change_mode(p_mode: Mode) -> void:
	if mode == p_mode:
		return

	# special value intended only for tools
	assert(p_mode != Mode.ANY)

	mode = p_mode
	mode_changed.emit(mode)


## Returns if our selection is empty or not.
func empty() -> bool:
	return entities.is_empty()


## Returns if our selection contains a specific [DoomEntity] or not.
func has(hit: DoomEntity) -> bool:
	return (hit in entities)


## Returns if our selection contains ANY from a list of [DoomEntity].
func has_any(hits: Array[DoomEntity]) -> bool:
	for hit: DoomEntity in hits:
		if not hit in entities:
			return false

	return true


## Returns if our selection contains ALL of a list of [DoomEntity].
func has_all(hits: Array[DoomEntity]) -> bool:
	if empty():
		return false

	for hit: DoomEntity in hits:
		if not hit in entities:
			return false

	return true


## Clears the current selection state.
func clear() -> void:
	entities.clear()


## Adds a list of [DoomEntity] to our selection.
## Handles checking for duplicates before adding.
func add(hits: Array[DoomEntity]) -> void:
	for hit: DoomEntity in hits:
		if not hit in entities:
			entities.push_back(hit)


## Removes a list of [DoomEntity] from our selection.
func remove(hits: Array[DoomEntity]) -> void:
	for hit: DoomEntity in hits:
		entities.erase(hit)


## Handles toggling the selection state of a list of [DoomEntity].
## If the entire list is already present, then this calls [method remove].
## Otherwise, it will call [method add].
func toggle(hits: Array[DoomEntity]) -> void:
	if has_all(hits):
		remove(hits)
	else:
		add(hits)


## Handles replacing the selection state with a list of [DoomEntity].
## If the list is empty, then the selection will be cleared.
func replace(hits: Array[DoomEntity]) -> void:
	clear()
	if not hits.is_empty():
		add(hits)


## Updates selection state, given a list of [DoomEntity].
## [param modifier] determines how to update the selection state.
func update(hits: Array[DoomEntity], modifier: Modifiers) -> void:
	match modifier:
		Modifiers.ADD:
			add(hits)
		Modifiers.REMOVE:
			remove(hits)
		Modifiers.REPLACE:
			replace(hits)
		Modifiers.TOGGLE:
			toggle(hits)
