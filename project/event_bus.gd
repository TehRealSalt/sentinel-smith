extends Node

# I like this pattern, but Godot does not agree with it.
@warning_ignore_start('unused_signal')

signal map_ready(file_name: String, map: DoomMap)

signal request_output()

signal selectable_2d_clicked(select: DoomSelectable2D)
