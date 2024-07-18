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
	
	for collision_polygon in collision_holder.get_children():
		var res = Geometry2D.clip_polygons(collision_polygon.polygon, offset_poly)
		
		if res.size() == 0:
			collision_polygon.queue_free()
			
		for i in range(res.size()):
			var clipped_collision = res[i]
			clipped_collision = Transform2D(0, Vector2(-map_size.x/2, -map_size.y/2)) * res[i]
			# These are awkward single or two-point floaters.
			if clipped_collision.size() < 3:
				continue
				
			if i == 0:
				#collision_polygon.call_deferred("set", "polygon", res)
				collision_polygon.set_deferred("polygon", res[0])
			else:
				var collider := CollisionPolygon2D.new()
				collider.polygon = clipped_collision
				collision_holder.call_deferred("add_child", collider)
		#
		#
		#if res.size() > 1:
			#var island := Polygon2D.new()
			#var island_collision := CollisionPolygon2D.new()
			#island.polygon = res[1]
			#island_collision.set_deferred('polygon',res[1])
			#add_child(island_collision)
			#add_child(island)
#
		#collision_polygon.set_deferred("polygon", res[0])

func create_circle_radious_polygon(position, radius: int) -> PackedVector2Array:
	var nb_points = 8
	var points_arc = PackedVector2Array()
	points_arc.push_back(position)
	
	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(i * 360 / nb_points)
		points_arc.push_back(position + Vector2(cos(angle_point), sin(angle_point)) * radius)
	return points_arc
