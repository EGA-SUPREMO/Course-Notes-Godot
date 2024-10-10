extends Attacking
class_name AI_Attacking

func update(_delta):
	player.angle -= 2 * _delta
	player.change_current_missile_to_next_missile_in_inventory()
	player.shoot.emit()
	transition.emit(self, "ai_idle")


func update_physics(_delta):
	super.update_physics(_delta)
