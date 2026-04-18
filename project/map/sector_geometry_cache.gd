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
		return

	var edges: Array[_Edge] = _make_edges()
	var adj: _AdjacencyMap = _AdjacencyMap.new(edges)
	polygons = _make_polygons(adj)
	valid = true


## Invalidates the cache. Should be called whenever the
## sector's shape has been modified.
func invalidate() -> void:
	valid = false


func _init(p_sector: DoomSector) -> void:
	sector = p_sector
	assert(sector)
