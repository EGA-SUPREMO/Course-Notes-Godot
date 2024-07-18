extends Node2D
@onready var polygon_2d = $Polygon2D
@onready var shape_sprite = $ShapeSprite
@onready var collision_holder = $CollisionHolder

var map_size: Vector2i

func _ready() -> void:
	create_collisions()
	
func create_collisions():	
	var bitMap = BitMap.new()
	bitMap.create_from_image_alpha(shape_sprite.texture.get_image())
	
	var polygons = bitMap.opaque_to_polygons(Rect2(Vector2(0, 0), bitMap.get_size()))

	#collision_polygon_2d.polygon = polygon_2d.polygon
	for polygon in polygons:
		var collider = CollisionPolygon2D.new()
		
		var newpoints := Array()
		for point in polygon:
			newpoints.push_back(point)
		collider.polygon = newpoints
		map_size = bitMap.get_size()
		collider.position.x -= bitMap.get_size().x/2
		collider.position.y -= bitMap.get_size().y/2
		collision_holder.add_child(collider)
		
func clip(poly: PackedVector2Array, global_position_missile: Vector2):
	var offset_poly = Polygon2D.new()
	offset_poly = Transform2D(0, Vector2(map_size.x/2, map_size.y/2)) * poly
	
	var res = Geometry2D.clip_polygons(collision_holder.get_child(0).polygon, offset_poly)
	
	collision_holder.get_child(0).set_deferred("polygon", res[0])

func create_circle_radious_polygon(position, radius: int) -> PackedVector2Array:
	var nb_points = 8
	var points_arc = PackedVector2Array()
	points_arc.push_back(position)
	
	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(i * 360 / nb_points)
		points_arc.push_back(position + Vector2(cos(angle_point), sin(angle_point)) * radius)
	return points_arc
