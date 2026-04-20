@abstract
class_name MapView2DLayer
extends Node2D
## Handles display of a single [MapView2D] layer.


## The [MapContainer] that this layer is for.
var container: MapContainer = null


## The [MapView2D] that this layer is for.
var view: MapView2D = null


## Quick pointer to our [RID] for [RenderingServer] functions.
@onready var rid: RID = get_canvas_item()


## How big to draw vertices.
const VERTEX_SIZE: float = 4.0


## How big to draw line normal indicators, in world space.
const LINE_NORMAL_SIZE: float = 8.0


## How transparent we display the indicator of the original
## position of a currently dragged element.
const DASHED_TRANSPARENT: float = 0.2


## Handles basic drawing of an arbitrary [DoomVertex].
func draw_map_vertex(vertex: DoomVertex, color: Color = Color.WHITE, dashed: bool = false) -> void:
	assert(vertex)
	if dashed:
		color.a *= DASHED_TRANSPARENT
	RenderingServer.canvas_item_add_circle(
		rid,
		vertex.position,
		VERTEX_SIZE,
		color
	) # not dashed


## Handles basic drawing of an arbitrary [DoomLinedef].
func draw_map_line(line: DoomLinedef, color: Color = Color.WHITE, dashed: bool = false) -> void:
	assert(line)
	var center: Vector2 = line.center()
	if dashed:
		color.a *= DASHED_TRANSPARENT
		draw_dashed_line(line.v1.position, line.v2.position, color, -1.0)
		draw_dashed_line(center, center + (line.normal() * LINE_NORMAL_SIZE), color, -1.0)
	else:
		RenderingServer.canvas_item_add_line(
			rid,
			line.v1.position,
			line.v2.position,
			color
		)
		RenderingServer.canvas_item_add_line(
			rid,
			center,
			center + (line.normal() * LINE_NORMAL_SIZE),
			color
		)


## Handles basic drawing of an arbitrary [DoomSector].
func draw_map_sector(sector: DoomSector, color: Color = Color.WHITE) -> void:
	assert(sector)
	sector.geometry_cache.validate()

	color.a *= 0.5

	for poly in sector.geometry_cache.polygons:
		if poly.triangles.is_empty():
			continue

		RenderingServer.canvas_item_add_triangle_array(
			rid,
			poly.triangles,
			poly.points,
			[color]
		)


## Handles basic drawing of an arbitrary [DoomThing].
func draw_map_thing(thing: DoomThing, color: Color = Color.WHITE, dashed: bool = false) -> void:
	assert(thing)
	var size := Vector2.ONE * DoomThing.TEMP_RADIUS
	var rect := Rect2(thing.position - size, size * 2.0)
	if dashed:
		color.a *= DASHED_TRANSPARENT
	RenderingServer.canvas_item_add_rect(
		rid,
		rect,
		color
	)
