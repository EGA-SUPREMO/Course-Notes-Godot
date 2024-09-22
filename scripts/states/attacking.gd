extends State
class_name Attacking

@export var player: CharacterBody2D

const SPEED = 100.0
const ACCELERATION = 10.0
	

func update(_delta):
	if Input.is_action_just_released(player.keyboard_profile + "shot"):
		player.shoot.emit()
		transition.emit(self, "idle")

func update_physics(_delta):
	var direction = Input.get_axis(player.keyboard_profile + "left_move", player.keyboard_profile + "right_move")
	
	if direction > 0:
		player.animated_sprite.flip_h = false
	elif direction < 0:
		player.animated_sprite.flip_h = true
	player.velocity.x = lerp(player.velocity.x, direction * SPEED, _delta * ACCELERATION)
	
