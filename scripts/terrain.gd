extends Node2D

@onready var island_holder = $IslandHolder
@onready var background: Sprite2D = $Background
@onready var background_2: Sprite2D = $ParallaxBackground/ParallaxLayer/Background2
@onready var map_generator: Node = $MapGenerator

const MIN_MASS_POLYGON := 200
const FORCE_MULTIPLIER_TO_POLYGONS = 1000

var backgrounds_textures = [preload("res://assets/backgrounds/background1.png"), 
preload("res://assets/backgrounds/background2.png"), 
preload("res://assets/backgrounds/background3.png"), 
preload("res://assets/backgrounds/background4.png")]

var colors_biome = [Color.LIGHT_YELLOW, Color.WEB_MAROON, Color.WHITE, Color.WEB_GREEN]
var biome_id: int

var signal_queue: Array = []


func _ready() -> void:
	biome_id = randi_range(0, 3)
	background_2.texture = backgrounds_textures[biome_id]
	#background.texture = maps[variant + biome_id * 3]
	
	add_to_group("destructibles")
	create_collisions()
	
	#background.offset = Globals.MAP_SIZE-map_size
	background_2.position.x += Globals.MAP_SIZE.x/2
	#background_2.position.y += Globals.MAP_SIZE.y/2
	
	background_2.scale.x = Globals.MAP_SIZE.x/background_2.texture.get_size().x
	background_2.scale.y = Globals.MAP_SIZE.y/background_2.texture.get_size().y
	
func _process(_delta: float) -> void:
	if signal_queue.size() > 0:
		var missile_node = signal_queue.pop_front()
		call_deferred("clip", create_circle_radious_polygon(missile_node.global_position, missile_node.damage + 15))
		call_deferred("apply_explotion_impulse", missile_node.global_position, missile_node.damage*FORCE_MULTIPLIER_TO_POLYGONS*missile_node.knockback_multiplier)
		#missile_node.queue_free()

func create_collisions():	
	var current_frecuency_amplitude = map_generator.frequencies_amplitudes[biome_id].pick_random()
	var current_amplitude_size = map_generator.general_amplitudes[biome_id]
	var noise_map = map_generator.generate_map(current_frecuency_amplitude, current_amplitude_size)
	var bitmap = map_generator.create_bitmap(noise_map)
	
	#for i in range(10):
		#noise_map = map_generator.generate_map(current_frecuency_amplitude, current_amplitude_size)
		#bitmap = map_generator.create_bitmap(noise_map)
		#bitmap.convert_to_image().save_jpg(str(i))
	#
	var polygons = bitmap.opaque_to_polygons(Rect2(Vector2(0, 0), Globals.MAP_SIZE), 1.5)
	
	for polygon in polygons:
		var collider = CollisionPolygon2D.new()
		
		var newpoints := Array()
		var body := StaticBody2D.new()
		var polygon_temp := Polygon2D.new()
		
		body.collision_layer = 3
		body.collision_mask = 3
		
		for point in polygon:
			newpoints.push_back(point)
		
		collider.polygon = newpoints
		collider.polygon = Transform2D(0, Vector2(0, Globals.MAP_SIZE.y-bitmap.get_size().y)) * collider.polygon
		polygon_temp.polygon = collider.polygon
		polygon_temp.color = colors_biome[biome_id]
		
		body.add_child(collider)
		body.add_child(polygon_temp)
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
			
		#for i in range(res.size() - 1, -1, -1):#has to go from size to 0, for some reason
		for i in range(res.size()):
			var clipped_collision = res[i]
			# These are awkward single or two-point floaters.
			if clipped_collision.size() < 3:
				continue
				
			if i == 0:
				collision_polygon.set_deferred("polygon", res[0])
				collision_body.get_child(1).set_deferred("polygon", res[0])
				
				if collision_body is RigidBody2D:
					var mass = abs(calculate_area(res[0]))
					if mass < MIN_MASS_POLYGON:
						collision_body.queue_free()
					collision_body.set_deferred("mass", mass)
					var centroid = calculate_centroid(clipped_collision)
					if abs(centroid) > Vector2(0.5, 0.5):
						collision_polygon.set_deferred("polygon",
							offset_polygon_by_center_of_mass(res[0], centroid))
						collision_body.get_child(1).set_deferred("polygon",
							offset_polygon_by_center_of_mass(res[0], centroid))
						
						collision_body.set_deferred("global_position", collision_body.global_position + centroid.rotated(collision_body.rotation))

			else:
				var collider := CollisionPolygon2D.new()
				var polygon_temp := Polygon2D.new()
				var body := RigidBody2D.new()
				body.collision_layer = 3
				body.collision_mask = 3
				
				var centroid = calculate_centroid(clipped_collision)
				collider.polygon = offset_polygon_by_center_of_mass(clipped_collision, centroid)
				polygon_temp.polygon = collider.polygon
				polygon_temp.color = colors_biome[biome_id]
				
				var mass = abs(calculate_area(collider.polygon))
				if mass < MIN_MASS_POLYGON:#too small
					return
				
				body.rotation = collision_body.rotation
				body.global_position = collision_body.position + centroid.rotated(collision_body.rotation)
				body.contact_monitor = true
				body.max_contacts_reported = 2
				body.mass = mass
				body.physics_material_override = preload("res://scene/missile/physics_material_bouncy.tres")
				
				island_holder.call_deferred("add_child", body)
				body.call_deferred("add_child", collider)
				body.call_deferred("add_child", polygon_temp)

	
func create_real_circle_radious_polygon(circle_position, radius: int) -> PackedVector2Array:
	var nb_points = 10
	var points_arc = PackedVector2Array()
	
	points_arc.push_back(circle_position)
	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(i * 360 / nb_points)
		points_arc.push_back(circle_position + Vector2(cos(angle_point), sin(angle_point)) * radius)

	return points_arc
	
func create_circle_radious_polygon(circle_position, radius: int) -> PackedVector2Array:
	var nb_points = 10
	var points_arc = PackedVector2Array()
	
	points_arc.push_back(circle_position)
	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(i * 360 / nb_points)
		# Stretch the shape vertically to form an upright egg
		var stretch_factor = 1.0 - 0.3 * sin(angle_point)
		var adjusted_radius_x = radius
		var adjusted_radius_y = radius * stretch_factor 
		
		points_arc.push_back(circle_position + Vector2(
			cos(angle_point) * adjusted_radius_x, 
			sin(angle_point) * adjusted_radius_y
		))

	return points_arc
	
func calculate_area(mesh_vertices: PackedVector2Array) -> float:
	var result := 0.0
	var num_vertices := mesh_vertices.size()
	
	for q in range(num_vertices):
		var p = (q - 1 + num_vertices) % num_vertices
		result += mesh_vertices[q].cross(mesh_vertices[p])
	
	return result * 0.5

func calculate_centroid(mesh_vertices: PackedVector2Array) -> Vector2:
	var centroid = Vector2()
	var area = calculate_area(mesh_vertices)
	var num_vertices = mesh_vertices.size()
	var factor = 0.0

	for q in range(num_vertices):
		var p = (q - 1 + num_vertices) % num_vertices
		factor = mesh_vertices[q].cross(mesh_vertices[p])
		centroid += (mesh_vertices[q] + mesh_vertices[p]) * factor

	centroid /= (6.0 * area)
	return centroid

func offset_polygon_by_center_of_mass(polygon: PackedVector2Array, center_of_mass: Vector2) -> PackedVector2Array:
	var offset_polygon = Transform2D(0, -center_of_mass) * polygon
	return offset_polygon

func apply_explotion_impulse(missile_position: Vector2, force: float) -> void:
	for collision_body in island_holder.get_children():
		if collision_body is RigidBody2D:
			var strength_knockback = Global.calculate_strength_knockback(collision_body.global_position,
				missile_position, force, collision_body.mass)
			collision_body.apply_impulse(strength_knockback, Vector2())

func destroy(missile) -> void:
	signal_queue.append(missile)
