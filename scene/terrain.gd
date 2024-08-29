extends Node2D

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
		
		var newpoints := Array()
		var body := StaticBody2D.new()
		
		body.collision_layer = 3
		body.collision_mask = 3
		
		for point in polygon:
			newpoints.push_back(point)
		
		collider.polygon = newpoints
		map_size = bitMap.get_size()
		
		body.add_child(collider)
		island_holder.add_child(body)
		
func clip(missile_polygon: PackedVector2Array):
	for collision_body in island_holder.get_children():
		var collision_polygon = collision_body.get_child(0)
		
		var offset_position = Vector2(-collision_body.global_position.x,
			-collision_body.global_position.y)
		offset_position = offset_position.rotated(-collision_body.rotation)
		
		var offset_missile_polygon := Transform2D(-collision_body.rotation,
			offset_position) * missile_polygon
		var res = Geometry2D.clip_polygons(collision_polygon.polygon, offset_missile_polygon)
		
		if res.size() == 0:
			collision_polygon.get_parent().queue_free()
			
		for i in range(res.size()):
			var clipped_collision = res[i]
			# These are awkward single or two-point floaters.
			if clipped_collision.size() < 3:
				continue
				
			if i == 0:
				collision_polygon.set_deferred("polygon", res[0])
				
				if collision_body is RigidBody2D:
					
					collision_body.set_deferred("mass", calculate_areaa(res[0]))
					var centroid = calculate_centroid(clipped_collision)
					if abs(centroid) > Vector2(0.05, 0.05):
						collision_polygon.set_deferred("polygon",
							offset_polygon_by_center_of_mass(res[0], centroid))
				
						collision_body.position = collision_body.position + centroid
						
						
						collision_body.get_child(1).position = collision_body.center_of_mass
					
			else:
				var collider := CollisionPolygon2D.new()
				var body := RigidBody2D.new()
				body.collision_layer = 3
				body.collision_mask = 3
				
				var centroid = calculate_centroid(clipped_collision)
				collider.polygon = offset_polygon_by_center_of_mass(clipped_collision, centroid)
				
				body.rotation = collision_body.rotation
				#collider.polygon = clipped_collision
				body.position = collision_body.position
				body.position = body.position + centroid
				# deberia usar el get del padre o del hijo?
				#body.position = centroid
				#body.global_position = body.global_position + centroid
				if collision_body is RigidBody2D:
					body.position += get_min_x_y(collider.polygon)
					#print(get_min_x_y(collision_polygon.polygon))
				#body.lock_rotation = true
				print("centroid: " + str(centroid))
				print("minxy: " + str(get_min_x_y(collider.polygon)))
				print("position: " + str(body.position))
				print("initial position: " + str(collision_body.position))
				print("padre centroid: " + str(calculate_centroid(collision_polygon.polygon)))
				
				body.freeze = true
				#body.center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_CUSTOM
				#body.center_of_mass = calculate_centroid(collider.polygon)
				#print(body.center_of_mass)
				
				body.mass = calculate_areaa(collider.polygon)
				
				var sprite = Sprite2D.new()
				var sprite2 = Sprite2D.new()
				var sprite3 = Sprite2D.new()
				sprite.texture = preload("res://assets/sprites/player_hud/shield_0.png")
				sprite2.texture = preload("res://assets/sprites/player_hud/shield_0.png")
				sprite3.texture = preload("res://assets/sprites/player_hud/shield_0.png")
				sprite.scale.x = 0.2
				sprite2.scale.x = 0.1
				sprite2.scale.y = 0.3
				sprite3.scale.x = 0.1315
				sprite3.scale.y = 2.15
				sprite.scale.y = 0.2
				sprite.position = body.center_of_mass
				sprite2.global_position = body.global_position
				sprite3.global_position = centroid#body.global_position + get_min_x_y(collider.polygon)
				island_holder.call_deferred("add_child", body)
				body.call_deferred("add_child", collider)
				body.call_deferred("add_child", sprite)
				call_deferred("add_child", sprite2)
				call_deferred("add_child", sprite3)
				
func create_circle_radious_polygon(position, radius: int) -> PackedVector2Array:
	var nb_points = 8
	var points_arc = PackedVector2Array()
	
	points_arc.push_back(position)
	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(i * 360 / nb_points)
		points_arc.push_back(position + Vector2(cos(angle_point), sin(angle_point)) * radius)

	return points_arc

func calculate_areaa(mesh_vertices: PackedVector2Array) -> float:
	var result := 0.0
	var num_vertices := mesh_vertices.size()

	for q in range(num_vertices):
		var p = (q - 1 + num_vertices) % num_vertices
		result += mesh_vertices[q].cross(mesh_vertices[p])
	
	return abs(result) * 0.5
	
func calculate_centroida(mesh_vertices: PackedVector2Array) -> Vector2:
	var centroid = Vector2()
	var area = 0.0
	var num_vertices = mesh_vertices.size()

	for q in range(num_vertices):
		var p = (q - 1 + num_vertices) % num_vertices
		var cross_product = mesh_vertices[q].cross(mesh_vertices[p])
		area += cross_product
		centroid += (mesh_vertices[q] + mesh_vertices[p]) * cross_product

	area = abs(area) * 0.5  # Correct area computation
	centroid /= (6.0 * area)
	#return centroid
	#print(centroid)
	#print(mesh_vertices)
	return centroid

func calculate_area(mesh_vertices: PackedVector2Array) -> float:
	var result := 0.0
	var num_vertices := mesh_vertices.size()
	
	for q in range(num_vertices):
		var p = (q - 1 + num_vertices) % num_vertices
		result += mesh_vertices[q].cross(mesh_vertices[p])
	
	return result * 0.5  # Remove abs to retain the sign

func calculate_centroid(mesh_vertices: PackedVector2Array) -> Vector2:
	var centroid = Vector2()
	var area = calculate_area(mesh_vertices)
	var num_vertices = mesh_vertices.size()
	var factor = 0.0

	for q in range(num_vertices):
		var p = (q - 1 + num_vertices) % num_vertices
		factor = mesh_vertices[q].cross(mesh_vertices[p])
		centroid += (mesh_vertices[q] + mesh_vertices[p]) * factor

	centroid /= (6.0 * area)  # Use area with its original sign
	return centroid


func offset_polygon_by_center_of_mass(polygon: PackedVector2Array, center_of_mass: Vector2) -> PackedVector2Array:
	var offset_polygon = Transform2D(0, -center_of_mass) * polygon
	#var offset_polygon = PackedVector2Array()
	#for point in polygon:
	#	offset_polygon.append(point - center_of_mass)
	
	#print(offset_polygon)
	#print(polygon)
	#print(center_of_mass)
	return offset_polygon

func get_min_x_y(points: PackedVector2Array) -> Vector2:
	var min_x = points[0].x
	var min_y = points[0].y

	for point in points:
		if point.x < min_x:
			min_x = point.x
		if point.y < min_y:
			min_y = point.y
	return Vector2(min_x, min_y)
