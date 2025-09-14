extends Node

var _timers: Dictionary[StringName, int] = {}


func start(id: StringName) -> void:
	assert(
		not (id in _timers),
		'Timer ID "%s" was already started.
		Make sure PerfTiming.end is being called,
		and that IDs are not being shared.' % id
	)

	_timers[id] = Time.get_ticks_usec()


func stop(id: StringName) -> void:
	assert(
		id in _timers,
		'Timer ID "%s" was never started.
		Make sure PerfTiming.start is being called,
		and that IDs are not being shared.' % id
	)

	var time_start := _timers[id]
	var time_end := Time.get_ticks_usec()
	print("[%s]: took %f sec." % [id, (time_end - time_start) / 1000000.0])

	_timers.erase(id)
