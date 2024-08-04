extends Node2D
#@onready var polygon_2d = $Polygon2D
@onready var shape_sprite = $ShapeSprite
@onready var island_holder = $IslandHolder

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
		#body.global_position.x -= bitMap.get_size().x/2
		#body.global_position.y -= bitMap.get_size().y/2
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
		
func clip(poly: PackedVector2Array, global_terrain_position: Vector2):
	for collision_body in island_holder.get_children():
		var collision_polygon = collision_body.get_child(0)
		
		#print("missil " + str(poly))
		#print(collision_polygon.global_position.x)
		#print(map_size.x/2)
		var offset_position = Vector2(collision_polygon.global_position.x - global_terrain_position.x,
			collision_polygon.global_position.y - global_terrain_position.y)
		print(collision_body.global_position.y)
		print(collision_body.position.y)
		#var offset_poly_island = Transform2D(0,
			#Vector2(offset_position.x,
				#offset_position.y)) * collision_polygon.polygon
		#
		var offset_poly = Transform2D(-collision_body.rotation,
			Vector2(-global_terrain_position.x + (collision_body.position.x - island_holder.position.x),
			-global_terrain_position.y + (collision_body.position.y - island_holder.position.y))) * poly
		#var offset_poly = Transform2D(0, #-collision_polygon.rotation,
			#Vector2(-global_terrain_position.x,
			#-global_terrain_position.y)) * poly
		#offset_poly = poly
		var poligono := Polygon2D.new()
		poligono.polygon = offset_poly
		add_child(poligono)
	
		
		#var offset_position_body = Transform2D(
		#	0, Vector2(position_body.x, position_body.y)) * collision_polygon.polygon
		var res = Geometry2D.clip_polygons(collision_polygon.polygon, offset_poly)
		#var res1 = Geometry2D.clip_polygons(offset_poly_island, offset_poly)
		
		
		if res.size() == 0:
			collision_polygon.get_parent().queue_free()
			
		for i in range(res.size()):
			
			#var new_res_position := Array()
			#for new_polygon in res:# da el res grande antes de anadirle los nuevos
			#	var p = Transform2D(0, offset_position) * new_polygon
			#	new_res_position.push_back(p)
			#var clipped_collision = new_res_position[i]
			var clipped_collision = res[i]
			#clipped_collision = Transform2D(0, Vector2(-map_size.x/2, -map_size.y/2)) * res[i]
			# These are awkward single or two-point floaters.
			if clipped_collision.size() < 3:
				continue
				
			if i == 0:
				collision_polygon.set_deferred("polygon", res[0])
			else:
				
				print("new_res {")
				#print(res1 == res)
				#print(new_res_position == res)
				print("}")
				
				
				
				
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
				#body.global_position.x -= map_size.x/2
				#body.global_position.y -= map_size.y/2
				body.center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_CUSTOM
				body.center_of_mass = Vector2(0, 0)
				#print(body.center_of_mass)
				island_holder.call_deferred("add_child", body)
				body.call_deferred("add_child", collider)
			#var island := Polygon2D.new()
			#island.polygon = res[1]
			#add_child(island)

func create_circle_radious_polygon(position, radius: int) -> PackedVector2Array:
	var nb_points = 4
	var points_arc = PackedVector2Array()
	points_arc.push_back(position)
	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(i * 360 / nb_points)
		points_arc.push_back(position + Vector2(cos(angle_point), sin(angle_point)) * radius)

	return points_arc
