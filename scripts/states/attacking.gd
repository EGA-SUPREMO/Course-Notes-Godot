extends State
class_name Attacking

@export var player: CharacterBody2D

	

func update(_delta):
	if Input.is_action_just_pressed(player.keyboard_profile + "shot"):
		player.shoot.emit()
		transition.emit(self, "idle")

func update_physics(_delta):
	var direction = Input.get_axis(player.keyboard_profile + "left_move", player.keyboard_profile + "right_move")
	
	if direction > 0:
		player.animated_sprite.flip_h = false
	elif direction < 0:
		player.animated_sprite.flip_h = true
	
	calculate_movement_speed(_delta, direction)
	
func calculate_movement_speed(_delta, direction):
	if player.stamina <= 0:
		direction = 0
	
	var max_movement = direction * player.SPEED_MOVEMENT
	var acceleration = lerp(player.velocity.x, direction * player.SPEED_MOVEMENT, _delta * player.ACCELERATION_MOVEMENT)
	
	if abs(max_movement) > abs(acceleration):
		player.velocity.x = acceleration
		player.stamina -= abs(player.velocity.x)/1000
	else:
		var desacceleration = lerp(player.velocity.x, direction * player.SPEED_MOVEMENT, _delta * player.DESACCELERATION_MOVEMENT)
		player.velocity.x = desacceleration
	
