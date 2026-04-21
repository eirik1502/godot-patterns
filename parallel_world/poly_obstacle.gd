extends Polygon2D

func _ready():
	var coll_poly = CollisionPolygon2D.new()
	coll_poly.polygon = self.polygon
	var bodies = find_children("*", "PhysicsBody2D")
	if bodies.is_empty():
		return
	var body = bodies[0]
	body.add_child(coll_poly)
