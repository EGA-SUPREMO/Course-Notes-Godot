extends State
class_name Idle

@export var player: CharacterBody2D

func enter() -> void:
	player.wants_shoot = false
	player.change_color_to_power(Color.GRAY)
	player.trajectory.default_color = Color.GRAY
	
func exit() -> void:
	if not player.wants_shoot:
		player.change_color_to_power(Globals.colors_by_player[player.resource_sprite_frame])

func update(_delta: float) -> void:
	#player.velocity.x = lerp(player.velocity.x, 0.0, _delta * player.DESACCELERATION_MOVEMENT)
	
	if Input.is_action_just_released(player.keyboard_profile + "shot"):
		player.wants_shoot = !player.wants_shoot
		player.second_shot_sfx.play()

func next_turn() -> void:
	transition.emit(self, "attacking")
