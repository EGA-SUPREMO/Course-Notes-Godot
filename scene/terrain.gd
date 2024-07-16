extends Node2D
@onready var polygon_2d = $Polygon2D
@onready var collision_polygon_2d = $Destructible/CollisionPolygon2D


func _ready() -> void:
	var bitMap = BitMap.new()
	bitMap.create_from_image_alpha(shape_sprite.texture.get_image())
	
	# debugging
	#shape_sprite.get_texture().get_image().save_png("res://screenshot.png")
	#bitMap.convert_to_image().save_png("res://screenshot.png")
	
	var polygons = bitMap.opaque_to_polygons(Rect2(Vector2(0, 0), bitMap.get_size()))

	collision_polygon_2d.polygon = polygon_2d.polygon
	
func clip(poly):
	var offset_poly = Polygon2D.new()
	print(poly)
	# Transform the polygon values to take into account the transform
	#offset_poly.polygon = poly.global_transform.xform(poly.polygon)
	offset_poly.polygon = poly
	
	var res = Geometry2D.clip_polygons($Polygon2D.polygon, offset_poly.polygon)

	$Polygon2D.polygon = res[0]
	$Destructible/CollisionPolygon2D.set_deferred("polygon", res[0])

	# Free the polygon to avoid memory leak
	offset_poly.queue_free()

func create_circle_radious_polygon(position, radius: int) -> PackedVector2Array:
	var nb_points = 8
	var points_arc = PackedVector2Array()
	points_arc.push_back(position)
	
	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(i * 360 / nb_points)
		points_arc.push_back(position + Vector2(cos(angle_point), sin(angle_point)) * radius)
	return points_arc
