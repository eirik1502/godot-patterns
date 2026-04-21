class_name PhysicsBodyChild
extends Node

@export
var velocity: Vector2 = Vector2.ZERO

@onready
var body: RigidBody2D = $RigidBody2D

func _physics_process(_delta):
	body.apply_central_force(velocity)
	await get_tree().physics_frame
