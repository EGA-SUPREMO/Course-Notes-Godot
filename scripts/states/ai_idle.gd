extends Idle
class_name IA_Idle


func next_turn() -> void:
	transition.emit(self, "ai_attacking")

func update(delta: float) -> void:
	player.velocity.x = lerp(player.velocity.x, 0.0, delta * player.DESACCELERATION_MOVEMENT)
