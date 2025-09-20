extends Window


func _on_close_requested() -> void:
	await hide()
	queue_free()
