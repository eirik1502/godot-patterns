class_name PwCharacter
extends CharacterBody2D

func _ready():
	self.velocity = Vector2.ONE * 1000

func _physics_process(delta):
	
	var move_vec = Vector2(
		int(Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_A)),
		int(Input.is_key_pressed(KEY_S)) - int(Input.is_key_pressed(KEY_W)),
	)
		
	self.move_and_slide()
	
	var coll: KinematicCollision2D = self.get_last_slide_collision()
	if coll:
		var impulse = -self.velocity.project(coll.get_normal()) * 2
		self.velocity += impulse
	
	self.rotation = self.velocity.angle()
