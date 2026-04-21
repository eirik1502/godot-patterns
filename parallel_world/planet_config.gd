class_name PlanetConfig
extends Node

@export
var planet_radius := 40.0
@export
var planet_dist := 40.0
@export
var planet_origin := Vector2(0, 0)

func _ready():
	PlanetConfig._instance = self

static func get_planet_radius() -> float:
	if is_instance_valid(_instance):
		return _instance.planet_radius
	else:
		return 0

static func get_planet_dist() -> float:
	if is_instance_valid(_instance):
		return _instance.planet_dist
	else:
		return 0
	
static func get_planet_origin() -> Vector2:
	if is_instance_valid(_instance):
		return _instance.planet_origin
	else:
		return Vector2.ZERO

static var _instance: PlanetConfig
