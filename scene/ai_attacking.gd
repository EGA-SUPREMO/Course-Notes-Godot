extends Attacking
class_name AI_Attacking

var missile: Missile
var has_aimed := false
var player_target: Player
var moving:= false

func _ready() -> void:
	player.death.connect(_on_player_death.bind(player))

func update(_delta):
	if not moving:#DONT MOVE FOR NOW TODO
		player.velocity.x = lerp(player.velocity.x, 0.0, _delta * player.DESACCELERATION_MOVEMENT)
	#if not player.can_shoot:
		#return
	if not player_target:
		select_target()
		return
	if randi_range(0, 40) != 40:#random wait
		return
	if not has_aimed:
		calculate_angle_and_power()
	if randi_range(1, 5) == 5:
		player.current_missile = 1
	elif randi_range(1, 6) == 5:
		player.current_missile = 3
	else:
		player.current_missile = 0
	player.missile_sprite.texture = Globals.PLAYABLE_MISSILE_ICONS[player.active_item_type][player.current_missile]
	player.shoot.emit()
	transition.emit(self, "ai_idle")
	has_aimed = false
	#player.add_child(trajectory)
#	if missile == null:
#		missile = Globals.PLAYABLE_MISSILES[2].instantiate()
		#print(player.apply_missile_shot(missile)  * player.missile_power * player.POWER_MULTIPLIER)
		#missile.collision_layer = 32
		#missile.collision_mask = 32
		#player.add_child(missile)
#		return
	#var collision = missile.move_and_collide(missile.linear_velocity, false, true, true)
	#print(missile.linear_velocity)
	#if collision:
	#	print(collision)
	#celebrate()
	
func celebrate():
	player.angle -= 15
	player.change_current_missile_to_next_missile_in_inventory()
	player.shoot.emit()
	if Globals.playable_missiles_nodes[player.current_missile].consumable:
		player.change_current_missile_to_next_missile_in_inventory()
		return
	transition.emit(self, "ai_idle")
	

func update_physics(_delta):
	super.update_physics(_delta)
	
func select_target():
	#player_target = MatchManager.players.get_children().pick_random()
	var players_node = get_tree().get_current_scene().get_node("/root/Main/Players")
	if not players_node:
		player_target = null
		return
	
	# Get the list of players
	var players = players_node.get_children()
	
	# If the current target is still valid, keep it
	if player_target and player_target in players and not randi_range(1, 5) == 5:
		return	
	var closest_player = null
	var min_distance = INF
	
	for p in players:
		if p != player:
			var distance = player.global_position.distance_to(p.global_position)
			if distance < min_distance:
				min_distance = distance
				closest_player = p
	
	player_target = closest_player
	
	
func calculate_angle_and_power():
	var shortest_distance = INF
	var best_angle = 0
	var best_power = 0
	var best_point = 0
	select_target()
	if not player_target:
		return
	
	for angle in 131:
		for power in 11:
			var points = player.trajectory.calculate_trajectory(angle * 3, power, 40, 2.0)
			for point in points:
				point += player.hud.global_position
				var distance = point.distance_to(player_target.global_position)
				if distance < shortest_distance:
					shortest_distance = distance
					best_angle = angle * 3
					best_power = power * 10
					best_point = point
	player.angle = best_angle
	player.missile_power = best_power
	has_aimed = true

func _on_player_death(_player):
	player_target = null
