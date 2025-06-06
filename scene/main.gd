extends Node2D

@onready var terrain = $Terrain
@onready var camera_2d = $Camera2D
@onready var void_limit: StaticBody2D = $VoidLimit
#@onready var players: Node = MatchManager.players
@onready var missiles: Node = $Missiles
@onready var players: Node = $Players
@onready var right_wall: CollisionShape2D = $Walls/Right
@onready var objects: Node = $Objects
@onready var effects: Node = $Effects

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
	fail_to_regenarate_sfx.volume_db = -10.0
	successful_regenaratation_sfx.stream = preload("res://assets/sounds/Kenney Gameplay/phaserUp6.ogg")
	add_child(successful_regenaratation_sfx)
	terrain.position.y = -Globals.MAP_SIZE.y/2
	right_wall.position.x = Globals.MAP_SIZE.x
	void_limit.position.y = Globals.MAP_SIZE.y/2
	camera_2d.limit_bottom = void_limit.position.y
	
	for player in MatchManager.players.get_children():
		MatchManager.players.remove_child(player)
		players.add_child(player)
	for player in players.get_children():
		player.shoot.connect(_on_player_shoot.bind(player))
		player.death.connect(_on_player_death.bind(player))
	
	
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
	
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		#camera_2d.zoom -= Vector2(0.01, 0.01)
	#if Input.is_key_pressed(KEY_BACKSPACE):
		#for child in missiles.get_children():
			#missiles.remove_child(child)
		
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		terrain.clip(terrain.create_circle_radious_polygon(
			get_global_mouse_position(), 50))
	#	camera_2d.zoom -= Vector2(0.01, 0.01)
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
	camera_2d.position.x = Globals.MAP_SIZE.x/2
	camera_2d.zoom.x = get_viewport().get_visible_rect().size.x / Globals.MAP_SIZE.x
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
	if player.HP <= 0:
		return
	if players.get_child_count() == 1:
		return
	var missile = Globals.PLAYABLE_MISSILES[player.active_item_type][player.selectedItem].instantiate()
	player.apply_missile_shot(missile)
	if missile.is_permanent:
		objects.add_child(missile)
	else:
		missile.add_to_group("missile")
		missiles.add_child(missile)
	
	if player.current_consumable == 2 and player.active_item_type:
		missile.effect.connect(_on_add_effect.bind(missile.animated_sprite_effect_node, missile))
	player.spend_current_missile_in_inventory()
	player.throw_sfx.pitch_scale = randf() + 0.75
	player.throw_sfx.play()

func _on_player_death(player: Player):
	player.animation_player.play("Death")
	player.death_sfx.play(0.3)
	var explotion = preload("res://scene/animated_explotion.tscn").instantiate()
	_on_add_effect(explotion, player)
	
	#next_round()

func _on_add_effect(effect: AnimatedSprite2D, parent: Node2D):
	if parent is Bat:
		effect.global_position = parent.last_position_collision
		effect.get_child(0).play()
	else:
		effect.global_position = parent.global_position
	effect.play()
	effects.add_child(effect)
