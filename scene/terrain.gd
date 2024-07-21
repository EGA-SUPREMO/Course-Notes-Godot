extends Node2D
@onready var polygon_2d = $Polygon2D
@onready var shape_sprite = $ShapeSprite
@onready var collision_holder = $IslandHolde/MainCollisionHolder
@onready var island_holder = $IslandHolde

var map_size: Vector2i


func _ready() -> void:
	create_collisions()
	
func create_collisions():	
	var bitMap = BitMap.new()
	bitMap.create_from_image_alpha(shape_sprite.texture.get_image())
	
	var polygons = bitMap.opaque_to_polygons(Rect2(Vector2(0, 0), bitMap.get_size()))
	
	
	for polygon in polygons:
		var collider = CollisionPolygon2D.new()
		#var drawed_polygon = Polygon2D.new()
		
		var newpoints := Array()
		for point in polygon:
			newpoints.push_back(point)
		
		collider.polygon = newpoints
		map_size = bitMap.get_size()
		collider.position.x -= bitMap.get_size().x/2
		collider.position.y -= bitMap.get_size().y/2
		#drawed_polygon.polygon = collider.polygon
		#drawed_polygon.position = collider.position
		collision_holder.add_child(collider)
		#add_child(drawed_polygon)
		
func clip(poly: PackedVector2Array, global_position_missile: Vector2):
	var offset_poly = Polygon2D.new()
	offset_poly = Transform2D(0, Vector2(map_size.x/2, map_size.y/2)) * poly
	
	for collision_polygon in island_holder.get_children():
		collision_polygon = collision_polygon.get_child(0)
		print(collision_polygon.to_string())
		print(collision_polygon.global_position)
		var res = Geometry2D.clip_polygons(collision_polygon.polygon, offset_poly)
		
		if res.size() == 0:
			collision_polygon.get_parent().queue_free()
			
		for i in range(res.size()):
			var clipped_collision = res[i]
			#clipped_collision = Transform2D(0, Vector2(-map_size.x/2, -map_size.y/2)) * res[i]
			# These are awkward single or two-point floaters.
			if clipped_collision.size() < 3:
				continue
				
			if i == 0:
				collision_polygon.set_deferred("polygon", res[0])
			else:
				var collider := CollisionPolygon2D.new()
				var body := RigidBody2D.new()
				body.collision_layer = 3
				body.collision_mask = 3
				collider.polygon = clipped_collision
				body.position = collider.position
				collider.position.x -= map_size.x/2
				collider.position.y -= map_size.y/2
				island_holder.call_deferred("add_child", body)
				body.call_deferred("add_child", collider)
			#var island := Polygon2D.new()
			#island.polygon = res[1]
			#add_child(island)

func create_circle_radious_polygon(position, radius: int) -> PackedVector2Array:
	var nb_points = 8
	var points_arc = PackedVector2Array()
	points_arc.push_back(position)
	
	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(i * 360 / nb_points)
		points_arc.push_back(position + Vector2(cos(angle_point), sin(angle_point)) * radius)
	return points_arc
