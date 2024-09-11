extends Node2D

var scene_missile = preload("res://scene/missile.tscn")
@onready var terrain = $Terrain
@onready var camera_2d = $Camera2D
@onready var void_limit: StaticBody2D = $VoidLimit

#@onready var rigid_body_2d = $RigidBody2D
#@onready var rigid_body_2d2 = $RigidBody2D2
#@onready var collision_polygon_2d = $RigidBody2D/CollisionPolygon2D
#@onready var collision_polygon_2d2 = $RigidBody2D2/CollisionPolygon2D
#var i = 0
func _ready():
	#rigid_body_2d.global_position = Vector2(-20, -100)
	#rigid_body_2d2.global_position = Vector2(0, 0)
	#collision_polygon_2d.polygon = PackedVector2Array(
		#[Vector2(30, 20), Vector2(30, 10), Vector2(20, 0), Vector2(10, 10)])
	#collision_polygon_2d2.polygon = PackedVector2Array(
		#[Vector2(-1030, -1020), Vector2(-1030, -1010), Vector2(-1020, -1000), Vector2(-1010, -1010)])
	#rigid_body_2d.center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_CUSTOM
	##rigid_body_2d2.center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_CUSTOM
	#rigid_body_2d.center_of_mass = terrain.calculate_centroid(collision_polygon_2d.polygon)
	##rigid_body_2d2.center_of_mass = terrain.calculate_centroid(collision_polygon_2d2.polygon)
	#
	#var rigid_body_2d2center_of_mass = terrain.calculate_centroid(collision_polygon_2d2.polygon)
	#collision_polygon_2d2.polygon = terrain.offset_polygon_by_center_of_mass(collision_polygon_2d2.polygon, rigid_body_2d2center_of_mass)
	#rigid_body_2d2.global_position += rigid_body_2d2center_of_mass
	#print(rigid_body_2d2.global_position)
	#print(rigid_body_2d.center_of_mass)
	#print(rigid_body_2d2.center_of_mass)
	pass
func _process(delta):
	adjust_camera()
	#if i > 200:
	#	var body = RigidBody2D.new()
	#	var collision = CollisionPolygon2D.new()
	#	collision.polygon = PackedVector2Array(
	#		[Vector2(0, -20), Vector2(-20, 0), Vector2(0, 20), Vector2(20, 0)])
	#	body.global_position.x = 300
	#	body.add_child(collision)
	#	add_child(body)
	#	i+=1
	#	body.collision_layer = 3
	#	body.collision_mask = 3
	
	if Input.is_action_pressed("reduce_zoom"):
		camera_2d.zoom.x += 0.5 * delta
		camera_2d.zoom.y += 0.5 * delta
		#i=0
	if Input.is_action_pressed("increase_zoom"):
		camera_2d.zoom.x -= 0.5 * delta
		camera_2d.zoom.y -= 0.5 * delta
		
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		terrain.clip(terrain.create_circle_radious_polygon(
			get_global_mouse_position(), $player.damage))	
	
		
func _on_player_shoot():
	var missile = scene_missile.instantiate()
	missile.add_to_group("missile")
	missile.rotation = $player.angle + PI / 2
	missile.position = $player/HUD.global_position
	var direction = Vector2(cos($player.angle), sin($player.angle))
	missile.apply_impulse(direction * $player.missile_power * 15, Vector2.ZERO)
	#missile.connect("explosion", terrain.destroy(position, 230))
	add_child(missile)

func adjust_camera() -> void:
	camera_2d.position.x = terrain.map_size.x/2
	camera_2d.position.y = get_y_from_x(get_viewport().get_visible_rect().size.x / terrain.map_size.x)# - get_viewport().get_visible_rect().size.y
	#camera_2d.position.y -=  - get_viewport().get_visible_rect().size.y/4
	camera_2d.zoom.x = get_viewport().get_visible_rect().size.x / terrain.map_size.x
	camera_2d.zoom.y = camera_2d.zoom.x

func get_y_from_x(x_value):#slope
	var m = 0.003332
	var b = 1.666
	return (x_value - b) / m
