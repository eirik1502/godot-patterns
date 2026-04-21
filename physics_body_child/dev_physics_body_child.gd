extends Node

@onready
var physics_body_child: PhysicsBodyChild = get_parent()

func _ready():
	physics_body_child.velocity = Vector2(100, 100)
