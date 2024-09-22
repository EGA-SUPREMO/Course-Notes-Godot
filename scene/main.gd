extends Node2D

@onready var terrain = $Terrain
@onready var camera_2d = $Camera2D
@onready var void_limit: StaticBody2D = $VoidLimit
@onready var player_1: CharacterBody2D = $Players/player
@onready var player_2: CharacterBody2D = $Players/player2
@onready var players: Node = $Players
@onready var missiles: Node = $Missiles

var scene_missile = preload("res://scene/missile.tscn")

var players_on_wait: bool
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
	camera_2d.limit_bottom = void_limit.position.y + 19#i dont know man, it has that offset
	player_2.animated_sprite.sprite_frames = preload("res://scene/player_risu.tres")
	
	players.get_child(0).state_machine.current_state.transition.emit(players.get_child(0).state_machine.current_state, "attacking")
	#players.get_child(0).state_machine.initial_state
	for player in players.get_children():
		player.shoot.connect(_on_player_shoot.bind(player))
		
func _process(_delta):
	adjust_camera()
	next_turn()#sholdnt run every update, but only after explotions
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
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		terrain.clip(terrain.create_circle_radious_polygon(
			get_global_mouse_position(), 50))	
	
	
func adjust_camera() -> void:
	camera_2d.position.x = terrain.map_size.x/2
	camera_2d.zoom.x = get_viewport().get_visible_rect().size.x / terrain.map_size.x
	camera_2d.zoom.y = camera_2d.zoom.x


func next_turn():
	players_on_wait = true
	for missile in missiles.get_children():
		if !missile.collision_shape_2d.disabled:
			return
	for player in players.get_children():
		if player.state_machine.current_state.name.to_lower()=="attacking" or player.state_machine.current_state.name.to_lower()=="ai_attacking":
			players_on_wait = false
	if players_on_wait:
		for player in players.get_children():
			player.state_machine.current_state.next_turn()

func _on_player_shoot(player) -> void:
	player.missile = scene_missile.instantiate()
	player.missile.add_to_group("missile")
	player.missile.rotation = player.angle + PI / 2
	player.missile.position = player.hud.global_position
	var direction = Vector2(cos(player.angle), sin(player.angle))
	player.missile.apply_impulse(direction * player.missile_power * 15, Vector2.ZERO)
	player.missile.who_shoot = player
	missiles.add_child(player.missile)
