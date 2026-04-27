class_name PolygonSourceShape
extends CollisionPolygon2D

@export
var polygon2D: Polygon2D

func _ready():
	if polygon2D:
		self.polygon = polygon2D.polygon
	else:
		push_warning("No Polygon2D assigned")
		
