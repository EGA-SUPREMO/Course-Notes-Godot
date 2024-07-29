extends Node2D
@onready var polygon_2d = $Polygon2D
@onready var shape_sprite = $ShapeSprite
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
		var body := StaticBody2D.new()
		
		body.collision_layer = 3
		body.collision_mask = 3
		
		for point in polygon:
			newpoints.push_back(point)
		
		collider.polygon = newpoints
		map_size = bitMap.get_size()
		body.global_position.x -= bitMap.get_size().x/2
		body.global_position.y -= bitMap.get_size().y/2
		#drawed_polygon.polygon = collider.polygon
		#drawed_polygon.position = collider.position
		var sprite_collider := Sprite2D.new()
		var sprite_rigidbody := Sprite2D.new()
		sprite_collider.texture = preload("res://assets/sprites/player_hud/shield_0.png")
		sprite_rigidbody.texture = preload("res://assets/sprites/player_hud/shield_0.png")
		sprite_collider.scale.x = 0.5
		sprite_collider.scale.y = 2.5
		#collider.add_child(sprite_collider)
		#body.add_child(sprite_rigidbody)
		
		body.add_child(collider)
		island_holder.add_child(body)
		#add_child(drawed_polygon)
		
func clip(poly: PackedVector2Array, global_position_missile: Vector2):
	var offset_poly = Transform2D(0, Vector2(map_size.x/2, map_size.y/2)) * poly
	
	for collision_polygon in island_holder.get_children():
		var position_body = collision_polygon.global_position
		collision_polygon = collision_polygon.get_child(0)

		print(collision_polygon.global_position)
		print(collision_polygon.position)
		print(collision_polygon.polygon)
		
		var offset_poly_island = Transform2D(0, Vector2(collision_polygon.global_position.x,
			collision_polygon.global_position.x)) * collision_polygon.polygon
	
		
		#var offset_position_body = Transform2D(
		#	0, Vector2(position_body.x, position_body.y)) * collision_polygon.polygon
		var res = Geometry2D.clip_polygons(collision_polygon.polygon, offset_poly)
		#var res = Geometry2D.clip_polygons(offset_poly_island, offset_poly)
		
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
				#var sprite_collider := Sprite2D.new()
				#var sprite_rigidbody := Sprite2D.new()
				#sprite_collider.texture = preload("res://assets/sprites/player_hud/shield_0.png")
				#sprite_rigidbody.texture = preload("res://assets/sprites/player_hud/shield_0.png")
				#sprite_collider.scale.x = 0.5 
				#collider.add_child(sprite_collider)
				#body.add_child(sprite_rigidbody)
				body.collision_layer = 3
				body.collision_mask = 3
				collider.polygon = clipped_collision
				body.position = collider.position
				#collider.position.x -= map_size.x/2
				#collider.position.y -= map_size.y/2
				body.center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_CUSTOM
				body.center_of_mass = Vector2(0, 0)
				#print(body.center_of_mass)
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
