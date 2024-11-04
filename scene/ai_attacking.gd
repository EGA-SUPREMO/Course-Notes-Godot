extends Attacking
class_name AI_Attacking

func update(_delta):
	player.angle -= 30
	player.change_current_missile_to_next_missile_in_inventory()
	player.shoot.emit()
	if Globals.playable_missiles_nodes[player.current_missile].consumable:
		player.change_current_missile_to_next_missile_in_inventory()
		return
	transition.emit(self, "ai_idle")
	

func update_physics(_delta):
	super.update_physics(_delta)
