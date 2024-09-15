extends State
class_name Idle

@export var player: CharacterBody2D

func enter() -> void:
	player.velocity.x = 0
	
func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	pass

func next_turn() -> void:
	transition.emit(self, "attacking")
