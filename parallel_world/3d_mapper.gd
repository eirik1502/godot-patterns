extends Node3D


@export var scale_factor: float = 1.0

@onready
var source_2d: Node2D = get_parent()

func _process(_delta):
	if source_2d == null:
		return
	
	var radius := 20.0
	
	var position_2d = source_2d.global_position / 100
	var rotation_2d := source_2d.global_rotation
	
	var dist = position_2d.length()
	if dist > (2.0 * PI * radius) / 4:
		self.visible = false
	else:
		self.visible = true
	
	var planet_angle = calc_planet_angle(radius, position_2d)
	var height = cos(planet_angle) * radius - radius
	var pos3 = (
		Vector3(position_2d.x, 0, position_2d.y).normalized()
		* sin(planet_angle) * radius
		+ Vector3(0, height, 0)
	)
	#var pos3 = Vector3(
		#position_2d.x * cos(planet_angle), 
		#height, 
		#position_2d.y * sin(planet_angle)
	#)
	
	var planet_normal = (pos3 + Vector3(0, radius, 0)).normalized()
	
	var world_right = Vector3(cos(rotation_2d), 0.0, sin(rotation_2d))
	var right = (world_right - planet_normal * world_right.dot(planet_normal)).normalized()
	var forward = planet_normal.cross(right).normalized()
	
	var basis = Basis(right, planet_normal, forward).orthonormalized()

	global_transform.basis = basis
	global_position = pos3

static func calc_planet_angle(radius: float, pos: Vector2) -> float:
	# The angle between the up vec of the planet and the pos curved around the surface
	var world_dist := pos.length();
	return world_dist / radius;


#static func calc_ground_pos_from_planet_angle(radius: float, float planet_angle, vec2 pos) {
#	float ground_dist = sin(planet_angle) * radius;
#	return normalize(pos) * ground_dist;
#}
