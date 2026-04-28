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
	
	var v = func(i, y):
		return Vector3(polygon[i].x * s, y, -polygon[i].y * s)

	var add_triangle = func(vertecies: Array):
		var to_1 = vertecies[1] - vertecies[0]
		var to_2 = vertecies[2] - vertecies[0]
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

	if depth < 0:
		polygon.reverse()
	var n = polygon.size()
	for i in range(n):
		var next = (i + 1) % n

		var a0 = v.call(i, 0.0)
		var b0 = v.call(next, 0.0)
		var b1 = v.call(next, depth)
		var a1 = v.call(i, depth)
		
		add_triangle.call([a0, b0, b1])
		add_triangle.call([a0, b1, a1])

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
