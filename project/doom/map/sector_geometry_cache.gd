class_name DoomSectorGeometryCache
extends RefCounted
## Holds geometry cache data for a [DoomSector].


## The [DoomSector] that this geometry cache is for.
var sector: DoomSector


## If the cache is considered to be holding proper values.
var valid: bool = false


class Polygon:
	extends RefCounted
	## Represents a single polygon for a [DoomSector].


	## Every vertex of this polygon.
	var points: PackedVector2Array = []


	## [member points] ran through [method Geometry2D.triangulate_polygon].
	var triangles: PackedInt32Array = []


	func _triangulate() -> PackedInt32Array:
		if points.size() < 3:
			return []

		if not points[0].is_equal_approx(points[points.size() - 1]):
			points.push_back(points[0])

		return Geometry2D.triangulate_polygon(points)


	func _init(p_points: PackedVector2Array) -> void:
		points = p_points
		triangles = _triangulate()


## Every [class Polygon] for our [DoomSector].
var polygons: Array[Polygon] = []


class _Edge:
	extends RefCounted


	var v1: DoomVertex
	var v2: DoomVertex


	func as_array() -> Array[DoomVertex]:
		return [v1, v2]


	func _init(p_v1: DoomVertex, p_v2: DoomVertex) -> void:
		v1 = p_v1
		v2 = p_v2
		assert(v1 and v2)


	static func make(line: DoomLinedef, side: DoomSidedef) -> _Edge:
		if line.side_back == side:
			return _Edge.new(line.v2, line.v1)
		else:
			return _Edge.new(line.v1, line.v2)


func _make_edges() -> Array[_Edge]:
	var edges: Array[_Edge] = []

	for side: DoomSidedef in sector.sides:
		for line: DoomLinedef in side.lines:
			edges.push_back(_Edge.make(line, side))

	return edges


class _AdjacencyMap:
	extends RefCounted

	var prev: Dictionary[DoomVertex, DoomVertex] = {}
	var next: Dictionary[DoomVertex, DoomVertex] = {}

	func _init(edges: Array[_Edge]) -> void:
		for edge: _Edge in edges:
			next[edge.v1] = edge.v2
			prev[edge.v2] = edge.v1


func _make_polygons(adj: _AdjacencyMap) -> Array[Polygon]:
	var polys: Array[Polygon] = []
	var visited: Dictionary[DoomVertex, bool] = {}

	# make open chains
	for v: DoomVertex in adj.next.keys():
		if adj.prev.has(v):
			continue

		var poly: PackedVector2Array = []
		var cur: DoomVertex = v

		while cur and not visited.get(cur, false):
			visited[cur] = true
			poly.push_back(cur.position)
			cur = adj.next.get(cur)

		polys.push_back(Polygon.new(poly))

	# make closed loops
	for v: DoomVertex in adj.next.keys():
		if visited.get(v, false):
			continue

		var poly: PackedVector2Array = []
		var cur: DoomVertex = v

		while cur and not visited.get(cur, false):
			visited[cur] = true
			poly.push_back(cur.position)
			cur = adj.next.get(cur)

		polys.push_back(Polygon.new(poly))

	return polys


## If the cache has been previously [method invalidate]'d,
## then reconstruct it. Should be called before using it.
func validate() -> void:
	if valid:
		# Wasn't invalidated, should be good
		return

	var edges: Array[_Edge] = _make_edges()
	var adj: _AdjacencyMap = _AdjacencyMap.new(edges)
	polygons = _make_polygons(adj)
	valid = true


## Invalidates the cache. Should be called whenever the
## sector's shape has been modified.
func invalidate() -> void:
	valid = false


## Test if a point was hit within this sector's geometry.
func test_point(world_point: Vector2) -> bool:
	validate()

	for poly: Polygon in polygons:
		if poly.triangles.is_empty():
			continue

		if Geometry2D.is_point_in_polygon(world_point, poly.points):
			return true

	return false


func _intersection(v1: Vector2, v2: Vector2, point: Vector2, normal: Vector2) -> Vector2:
	var line_delta: Vector2 = v2 - v1
	var point_delta: Vector2 = point - v1
	var frac: float = point_delta.dot(normal) / line_delta.dot(normal)
	return v1 + (line_delta * frac)


func _clip_against_edge(points: PackedVector2Array, edge_point: Vector2, edge_normal: Vector2) -> PackedVector2Array:
	var result: PackedVector2Array = []

	var num_points: int = points.size()
	for i in range(num_points):
		var v1: Vector2 = points[i]
		var v2: Vector2 = points[(i + 1) % num_points]

		var v1_inside: bool = ((v1 - edge_point).dot(edge_normal) >= 0.0)
		var v2_inside: bool = ((v2 - edge_point).dot(edge_normal) >= 0.0)

		if v1_inside and v2_inside:
			result.push_back(v2)
		elif v1_inside and not v2_inside:
			result.push_back(_intersection(v1, v2, edge_point, edge_normal))
		elif not v1_inside and v2_inside:
			result.push_back(_intersection(v1, v2, edge_point, edge_normal))
			result.push_back(v2)

	return result


func _clip_against_rect(points: PackedVector2Array, rect: Rect2) -> PackedVector2Array:
	var output: PackedVector2Array = points.duplicate()
	output = _clip_against_edge(output, rect.position, Vector2.RIGHT)
	output = _clip_against_edge(output, rect.position + Vector2(rect.size.x, 0.0), Vector2.LEFT)
	output = _clip_against_edge(output, rect.position, Vector2.DOWN)
	output = _clip_against_edge(output, rect.position + Vector2(0.0, rect.size.y), Vector2.UP)
	return output


func _poly_area(points: PackedVector2Array) -> float:
	var area: float = 0.0
	var size: int = points.size()

	if size < 3:
		return 0.0

	for i in range(size):
		var v1: Vector2 = points[i]
		var v2: Vector2 = points[(i + 1) % size]
		area += v1.x * v2.y - v2.x * v1.y

	return area * 0.5


## Test if a rectangle touches this sector's geometry.
func test_rect(world_rect: Rect2, threshold: float = 0.5) -> bool:
	validate()

	for poly: Polygon in polygons:
		if poly.triangles.is_empty():
			continue

		var area: float = absf(_poly_area(poly.points))
		if area == 0.0:
			continue

		var clipped: PackedVector2Array = _clip_against_rect(poly.points, world_rect)
		var area_clipped: float = absf(_poly_area(clipped))
		if area_clipped > threshold * area:
			return true

	return false


func _init(p_sector: DoomSector) -> void:
	sector = p_sector
	assert(sector)
