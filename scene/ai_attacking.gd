extends Attacking
class_name AI_Attacking

var missile: Missile
var has_target := false
var player_target: Player

func update(_delta):
	if not has_target:
		select_target()
		return
	
	calculate_angle_and_power()
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
	player_target = MatchManager.players.get_children().pick_random()

func calculate_angle_and_power():
	player.trajectory.update_trajectory(player.angle, player.missile_power, 40, 2.0)
	
