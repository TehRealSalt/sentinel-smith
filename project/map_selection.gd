class_name MapSelection
extends RefCounted
## Manages selection state for a [MapContainer].


## Different ways of updating the selection state.
## Used for [method update].
enum Modifiers
{
	TOGGLE,
	ADD,
	REMOVE
}


## Pointer to the [MapContainer] that this selection applies to.
var container: MapContainer = null


## All [DoomEntity] references that are considered selected.
var entities: Array[DoomEntity] = []


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


## Updates selection state, given a list of [DoomEntity].
## [param modifier] determines how to update the selection state.
## If [param hits] is empty, then the selection will be cleared.
func update(hits: Array[DoomEntity], modifier: Modifiers) -> void:
	if hits.is_empty():
		clear()
		return

	match modifier:
		Modifiers.TOGGLE:
			toggle(hits)
		Modifiers.ADD:
			add(hits)
		Modifiers.REMOVE:
			remove(hits)
