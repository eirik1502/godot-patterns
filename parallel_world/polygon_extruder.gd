extends Node

@export
var polygon: Polygon2D

var depth = -5

@onready
var _mesh_instance: MeshInstance3D = get_parent()

func _ready():
	_rebuild()

func _rebuild():
	#var mesh = polygon_to_mesh(polygon.polygon)
	var mesh = extrude_polygon(polygon.polygon, depth)
	if is_instance_valid(_mesh_instance):
		_mesh_instance.mesh = mesh
		var material = StandardMaterial3D.new()
		material.albedo_color = polygon.color
		_mesh_instance.material_override = material

static func extrude_polygon(polygon: PackedVector2Array, depth: float) -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var s = 0.01
	var indices = Geometry2D.triangulate_polygon(polygon)
	
	var v = func(i, y_depth: float):
		return Vector3(polygon[i].x * s, y_depth, -polygon[i].y * s)

	var add_triangle = func(vertecies: Array):
		var to_1 = vertecies[1] - vertecies[0]
		var to_2 = vertecies[2] - vertecies[0]
		## Must match cap winding (indices / reverse below); sides use their own vertex order.
		var normal = to_2.cross(to_1).normalized()
		for vertex in vertecies:
			st.set_normal(normal)
			st.add_vertex(vertex)
	
	var add_face = func(indices_indices: Array, z: float):
		var a_i = indices[indices_indices[0]]
		var b_i = indices[indices_indices[1]]
		var c_i = indices[indices_indices[2]]
		
		var a = v.call(a_i, z)
		var b = v.call(b_i, z)
		var c = v.call(c_i, z)
		
		add_triangle.call([a, b, c])
		
	if depth < 0:
		indices.reverse()

	for i in range(0, indices.size(), 3):
		add_face.call([i, i+1, i+2], 0.0)

	for i in range(0, indices.size(), 3):
		add_face.call([i, i+2, i+1], depth)

	## Side walls: outward normals depend on boundary traversal (CW vs CCW). Caps use
	## triangulation on `polygon` as-is; normalize here so walls match simple convex shapes
	## and hand-drawn polygons that were authored with opposite winding.
	var edge_loop: PackedVector2Array = polygon.duplicate()
	if Geometry2D.is_polygon_clockwise(edge_loop):
		edge_loop.reverse()
	if depth < 0:
		edge_loop.reverse()
	var edge_pt = func(verts: PackedVector2Array, idx: int, y_depth: float) -> Vector3:
		var p = verts[idx]
		return Vector3(p.x * s, y_depth, -p.y * s)
	var n_edge = edge_loop.size()
	for i in range(n_edge):
		var next_i = (i + 1) % n_edge

		var a0 = edge_pt.call(edge_loop, i, 0.0)
		var b0 = edge_pt.call(edge_loop, next_i, 0.0)
		var b1 = edge_pt.call(edge_loop, next_i, depth)
		var a1 = edge_pt.call(edge_loop, i, depth)

		add_triangle.call([a0, b1, b0])
		add_triangle.call([a0, a1, b1])

	#st.generate_normals()

	var mesh = ArrayMesh.new()
	st.commit(mesh)
	return mesh

static func polygon_to_mesh(
	polygon: PackedVector2Array,
	color: Color = Color.WHITE,
) -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var indices = Geometry2D.triangulate_polygon(polygon)
	indices.reverse()
	
	for i in indices:
		var v = polygon[i]
		var v_scaled = v / 100
		st.add_vertex(Vector3(v_scaled.x, 0.0, -v_scaled.y))

	st.generate_normals()

	var mesh = st.commit()
	return mesh
