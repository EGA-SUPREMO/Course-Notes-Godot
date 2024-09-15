extends State
class_name Attacking
@export var player: CharacterBody2D

signal shoot
const SPEED = 100.0

func update(_delta):
	if Input.is_action_just_released("shot"):
		shoot.emit()
		transition.emit(self, "idle")

func update_physics(_delta):
	var direction = Input.get_axis("left_move", "right_move")

	if direction > 0:
		player.animated_sprite.flip_h = false
	elif direction < 0:
		player.animated_sprite.flip_h = true
	
	if direction:
		player.velocity.x = direction * SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
