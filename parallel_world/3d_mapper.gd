extends Node3D

@onready
var source_2d: Node2D = get_parent()

func _process(_delta):
	if source_2d == null:
		return
	
	var radius := PlanetConfig.get_planet_radius()
	var planet_dist := PlanetConfig.get_planet_dist()
	var planet_origin := PlanetConfig.get_planet_origin()

	var position_2d = source_2d.global_position / 100
	var rotation_2d := source_2d.global_rotation
	
	var planet_angle = calc_planet_angle(radius, position_2d)
	var height = cos(planet_angle) * radius
	var planet_position_2d = position_2d.normalized() * sin(planet_angle) * radius
	
	self.visible = position_2d.length() <= radius
	
	var sphere_position_3d = Vector3(
		planet_position_2d.x,
		height,
		planet_position_2d.y,
	)
	var translate_3d = Vector3(planet_origin.x, -planet_dist, planet_origin.y)
	var position_3d = sphere_position_3d + translate_3d
	
	var planet_normal = sphere_position_3d.normalized()
	var world_right = Vector3(cos(rotation_2d), 0.0, sin(rotation_2d))
	var right = (world_right - planet_normal * world_right.dot(planet_normal)).normalized()
	var forward = planet_normal.cross(right).normalized()	
	var basis = Basis(right, planet_normal, forward).orthonormalized()

	global_transform.basis = basis
	global_position = position_3d

static func calc_planet_angle(radius: float, pos: Vector2) -> float:
	# The angle between the up vec of the planet and the pos curved around the surface
	var world_dist := pos.length();
	return world_dist / radius;


#static func calc_ground_pos_from_planet_angle(radius: float, float planet_angle, vec2 pos) {
#	float ground_dist = sin(planet_angle) * radius;
#	return normalize(pos) * ground_dist;
#}
