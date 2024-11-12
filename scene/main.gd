extends Node2D

@onready var terrain = $Terrain
@onready var camera_2d = $Camera2D
@onready var void_limit: StaticBody2D = $VoidLimit
#@onready var players: Node = MatchManager.players
@onready var missiles: Node = $Missiles
@onready var players: Node = $Players

var players_on_wait: bool
#@onready var rigid_body_2d = $RigidBody2D
#@onready var rigid_body_2d2 = $RigidBody2D2
#@onready var collision_polygon_2d = $RigidBody2D/CollisionPolygon2D
#@onready var collision_polygon_2d2 = $RigidBody2D2/CollisionPolygon2D
#var i = 0

static var fail_to_regenarate_sfx: AudioStreamPlayer
static var successful_regenaratation_sfx: AudioStreamPlayer

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
	fail_to_regenarate_sfx = AudioStreamPlayer.new()
	fail_to_regenarate_sfx.bus = "SFX"
	fail_to_regenarate_sfx.volume_db = 10.0
	fail_to_regenarate_sfx.stream = preload("res://assets/sounds/buy_fail2.wav")
	add_child(fail_to_regenarate_sfx)
	
	successful_regenaratation_sfx = AudioStreamPlayer.new()
	successful_regenaratation_sfx.bus = "SFX"
	fail_to_regenarate_sfx.volume_db = 9.0
	successful_regenaratation_sfx.stream = preload("res://assets/sounds/bolt sliding back from Pixabay.mp3")
	add_child(successful_regenaratation_sfx)
	
	camera_2d.limit_bottom = void_limit.position.y
	
	for player in MatchManager.players.get_children():
		
		MatchManager.players.remove_child(player)
		players.add_child(player)
	for player in players.get_children():
		player.shoot.connect(_on_player_shoot.bind(player))
		player.death.connect(_on_player_death.bind(player))
	#add_child(players)
	#player_2.queue_free()

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
		#for missile in missiles.get_children():
			
		#	var direction = Vector2(cos(deg_to_rad(missile.rotation)), sin(deg_to_rad(missile.rotation)))
		#	missile.apply_impulse(direction * 5000 * 15, Vector2.ZERO)
	
	
func go_around_map():	
	for polygon in missiles.get_children():
		if polygon.global_position.x < 0:
			var new_global_position_x = terrain.map_size.x - polygon.global_position.x
			polygon.set_deferred("global_position",
				Vector2(new_global_position_x, polygon.global_position.y))
		elif polygon.global_position.x > terrain.map_size.x:
			var new_global_position_x = polygon.global_position.x - terrain.map_size.x
			polygon.set_deferred("global_position", 
				Vector2(new_global_position_x, polygon.global_position.y))
	
func adjust_camera() -> void:
	camera_2d.position.x = terrain.map_size.x/2
	camera_2d.zoom.x = get_viewport().get_visible_rect().size.x / terrain.map_size.x
	camera_2d.zoom.y = camera_2d.zoom.x


func next_turn():
	players_on_wait = true
	
	if players.get_child_count() <= 1 and not missiles.get_child_count():
		next_round()
	
	for missile in missiles.get_children():
		if !missile.collision_shape_2d.disabled:
			return
	for player in players.get_children():
		if player.state_machine.current_state.name.to_lower()=="attacking" or player.state_machine.current_state.name.to_lower()=="ai_attacking":
			return
	
	if players_on_wait:
		for player in players.get_children():
			player.state_machine.current_state.next_turn()

func next_round():
	Globals.counting()
	var i = 0
	for player in players.get_children():
		i += 1
		player.win_count += 1
		player.money += 3000
		players.remove_child(player)
		MatchManager.players.call_deferred("add_child", player)
	
	if i > 1: print("problemon, dos players obtuvieron bonus de ganador")
	if Globals.current_match_count >= Globals.max_number_match:
		MatchManager.call_deferred("prepare_new_match")
		get_tree().change_scene_to_file("res://scene/winner_page.tscn")
		return
	
	MatchManager.call_deferred("sort_players_node_by_id")
	get_tree().change_scene_to_file("res://scene/shop.tscn")

func _on_player_shoot(player) -> void:
	if players.get_child_count() == 1:
		return
	var missile = Globals.PLAYABLE_MISSILES[player.current_missile].instantiate()
	missile.add_to_group("missile")
	missile.rotation = deg_to_rad(player.angle) + PI / 2
	missile.position = player.hud.global_position
	var direction = Vector2(cos(deg_to_rad(player.angle)), sin(deg_to_rad(player.angle)))
	missile.apply_impulse(direction * player.missile_power * 9, Vector2.ZERO)
	missile.who_shoot = player
	missiles.add_child(missile)

	player.spend_current_missile_in_inventory()

func _on_player_death(player: Player):
	players.remove_child(player)
	MatchManager.players.call_deferred("add_child", player)
