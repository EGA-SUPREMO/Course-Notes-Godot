extends State
class_name Idle

@export var player: CharacterBody2D

func enter() -> void:
	pass

func exit() -> void:
	player.change_color_to_power(Globals.colors_by_player[player.resource_sprite_frame])

	
func update(_delta: float) -> void:
	player.velocity.x = lerp(player.velocity.x, 0.0, _delta * player.DESACCELERATION_MOVEMENT) 

func next_turn() -> void:
	transition.emit(self, "attacking")
