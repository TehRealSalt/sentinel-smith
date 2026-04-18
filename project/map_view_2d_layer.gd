@abstract
class_name MapView2DLayer
extends Node2D
## Handles display of a single [MapView2D] layer.


## The [MapContainer] that this layer is for.
var container: MapContainer = null


## The [MapView2D] that this layer is for.
var view: MapView2D = null


## How big to draw line normal indicators, in world space.
const LINE_NORMAL_SIZE: float = 8.0


## How transparent we display the indicator of the original
## position of a currently dragged element.
const DASHED_TRANSPARENT: float = 0.2


## Handles basic drawing of an arbitrary [DoomVertex].
func draw_map_vertex(vertex: DoomVertex, color: Color = Color.WHITE, dashed: bool = false) -> void:
	assert(vertex)
	var size := Vector2.ONE * 2.0
	var rect := Rect2(vertex.position - size, size * 2.0)
	if dashed:
		color.a *= DASHED_TRANSPARENT
	draw_rect(rect, color, false)


## Handles basic drawing of an arbitrary [DoomLinedef].
func draw_map_line(line: DoomLinedef, color: Color = Color.WHITE, dashed: bool = false) -> void:
	assert(line)
	var center: Vector2 = line.center()
	if dashed:
		color.a *= DASHED_TRANSPARENT
		draw_dashed_line(line.v1.position, line.v2.position, color, -1.0)
		draw_dashed_line(center, center + (line.normal() * LINE_NORMAL_SIZE), color, -1.0)
	else:
		draw_line(line.v1.position, line.v2.position, color, -1.0)
		draw_line(center, center + (line.normal() * LINE_NORMAL_SIZE), color, -1.0)


## Handles basic drawing of an arbitrary [DoomThing].
func draw_map_thing(thing: DoomThing, color: Color = Color.WHITE, dashed: bool = false) -> void:
	assert(thing)
	var size := Vector2.ONE * 8.0
	var rect := Rect2(thing.position - size, size * 2.0)
	if dashed:
		color.a *= DASHED_TRANSPARENT
	draw_rect(rect, color, false)
