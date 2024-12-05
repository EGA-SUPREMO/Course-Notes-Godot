extends Attacking
class_name AI_Attacking

var missile: Missile

#func update(_delta):
	
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
