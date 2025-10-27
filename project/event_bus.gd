extends Node

# TODO: Actually I decided I hate global signalling, kill this file
@warning_ignore_start('unused_signal')

signal map_ready(file_name: String, map: DoomMap)

signal request_output()

signal selectable_2d_entered(select: DoomSelectable2D)
signal selectable_2d_exited(select: DoomSelectable2D)
