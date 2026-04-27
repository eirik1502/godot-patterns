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

	# -------------------
	# FRONT FACE (use triangulation directly, no fan)
	# -------------------
	for i in range(0, indices.size(), 3):
		var a = indices[i]
		var b = indices[i + 1]
		var c = indices[i + 2]

		st.add_vertex(v.call(a, 0.0))
		st.add_vertex(v.call(b, 0.0))
		st.add_vertex(v.call(c, 0.0))

	# -------------------
	# BACK FACE (same triangles, reversed winding)
	# -------------------
	for i in range(0, indices.size(), 3):
		var a = indices[i]
		var b = indices[i + 1]
		var c = indices[i + 2]

		st.add_vertex(v.call(a, depth))
		st.add_vertex(v.call(c, depth))
		st.add_vertex(v.call(b, depth))

	# -------------------
	# SIDES (edge-based, independent of triangulation)
	# -------------------
	var n = polygon.size()

	for i in range(n):
		var next = (i + 1) % n

		var a0 = v.call(i, 0.0)
		var b0 = v.call(next, 0.0)
		var b1 = v.call(next, depth)
		var a1 = v.call(i, depth)

		st.add_vertex(a0)
		st.add_vertex(b0)
		st.add_vertex(b1)

		st.add_vertex(a0)
		st.add_vertex(b1)
		st.add_vertex(a1)

	st.generate_normals()

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
