class_name MapOutputWindow
extends Window

@onready var label := %Text as RichTextLabel

var output_string: String = '':
	set(v):
		output_string = v

		if label:
			label.text = output_string


func _on_close_requested() -> void:
	await hide()
	queue_free()


func _ready() -> void:
	if label:
		label.text = output_string
