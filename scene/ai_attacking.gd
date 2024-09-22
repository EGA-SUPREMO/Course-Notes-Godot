extends Attacking
class_name AI_Attacking

func update(_delta):
	player.angle -= 2 * _delta
	player.shoot.emit()
	transition.emit(self, "ai_idle")


func update_physics(_delta):
	super.update_physics(_delta)
