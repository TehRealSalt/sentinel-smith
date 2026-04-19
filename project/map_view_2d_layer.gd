@abstract
class_name MapView2DLayer
extends Node2D
## Handles display of a single [MapView2D] layer.


## The [MapContainer] that this layer is for.
var container: MapContainer = null


## The [MapView2D] that this layer is for.
var view: MapView2D = null


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
	draw_circle(vertex.position, VERTEX_SIZE, color, not dashed)


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


## Handles basic drawing of an arbitrary [DoomSector].
func draw_map_sector(sector: DoomSector, color: Color = Color.WHITE) -> void:
	assert(sector)
	sector.geometry_cache.validate()

	color.a *= 0.5

	for poly: DoomSectorGeometryCache.Polygon in sector.geometry_cache.polygons:
		# overcomplicated, but it's so that we can cache the
		# triangulation process instead of requiring the
		# drawer to do this
		for t: int in range(0, poly.triangles.size(), 3):
			var tri_polygon := PackedVector2Array([
				poly.points[poly.triangles[t]],
				poly.points[poly.triangles[t + 1]],
				poly.points[poly.triangles[t + 2]]
			])
			# TODO: move to RenderingServer.canvas_item_add_triangle_array()
			draw_colored_polygon(tri_polygon, color)


## Handles basic drawing of an arbitrary [DoomThing].
func draw_map_thing(thing: DoomThing, color: Color = Color.WHITE, dashed: bool = false) -> void:
	assert(thing)
	var size := Vector2.ONE * DoomThing.TEMP_RADIUS
	var rect := Rect2(thing.position - size, size * 2.0)
	if dashed:
		color.a *= DASHED_TRANSPARENT
	draw_rect(rect, color, false)
