extends Idle
class_name IA_Idle


func next_turn() -> void:
	transition.emit(self, "ai_attacking")
