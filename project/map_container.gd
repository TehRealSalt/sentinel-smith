class_name MapContainer
extends Control
## A tab for which contains the [DoomMap] and all of the methods
## to inspect and interact with its data.


@onready var _view_2d: MapView2D = %MapView2D


## The map that this container represents.
var map: DoomMap = null


## Our undo/redo state.
var undo_redo := UndoRedo.new()


## Our selection state.
var selection := MapSelection.new(self)


## Our drag state.
var drag := MapDrag.new(self)


func _ready() -> void:
	_view_2d.container = self
