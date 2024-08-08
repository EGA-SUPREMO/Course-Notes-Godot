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
		
func clip(poly: PackedVector2Array):
	for collision_body in island_holder.get_children():
		var collision_polygon = collision_body.get_child(0)
		
		var offset_position = Vector2(-collision_body.global_position.x,
			-collision_body.global_position.y)
		offset_position = offset_position.rotated(-collision_body.rotation)
		
		var offset_poly := Transform2D(-collision_body.rotation,
			offset_position) * poly
		var res = Geometry2D.clip_polygons(collision_polygon.polygon, offset_poly)
		
		
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
					collision_body.center_of_mass = calculate_centroid(res[0])
					collision_body.mass = calculate_area(res[0])
				
			else:
				var collider := CollisionPolygon2D.new()
				var body := RigidBody2D.new()
				body.collision_layer = 3
				body.collision_mask = 3
				
				collider.polygon = clipped_collision
				body.global_position = collision_body.position

				body.rotation = collision_body.rotation
								
				body.center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_CUSTOM
				body.center_of_mass = calculate_centroid(collider.polygon)
				body.mass = calculate_area(collider.polygon)
				
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

func calculate_area(mesh_vertices: PackedVector2Array) -> float:
	var result := 0.0
	var num_vertices := mesh_vertices.size()

	for q in range(num_vertices):
		var p = (q - 1 + num_vertices) % num_vertices
		result += mesh_vertices[q].cross(mesh_vertices[p])
	
	return abs(result) * 0.5

func calculate_centroid(mesh_vertices: PackedVector2Array) -> Vector2:
	var centroid = Vector2()
	var area = calculate_area(mesh_vertices)
	var num_vertices = mesh_vertices.size()
	var factor = 0.0

	for q in range(num_vertices):
		var p = (q - 1 + num_vertices) % num_vertices
		factor = mesh_vertices[q].x * mesh_vertices[p].y - mesh_vertices[p].x * mesh_vertices[q].y
		centroid += (mesh_vertices[q] + mesh_vertices[p]) * factor

	centroid /= (6.0 * area)
	return -centroid
