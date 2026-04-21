extends ReferenceRect

@export
var amount: int = 10
@export
var scene: PackedScene

func _ready():
	await get_parent().ready
	for i in range(amount):
		var node: Node2D = scene.instantiate()
		node.position = _pick_position()
		self.add_sibling(node)
		

func _pick_position() -> Vector2:
	var rect = self.get_global_rect()
	return Vector2(
		randf_range(rect.position.x, rect.end.x),
		randf_range(rect.position.y, rect.end.y),
	)
