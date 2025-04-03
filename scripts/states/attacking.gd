extends State
class_name Attacking

@export var player: CharacterBody2D

func enter():
	if player.trajectory:
		player.change_color_to_power(Globals.colors_by_player[player.resource_sprite_frame])
		player.trajectory.default_color = Globals.colors_by_player[player.resource_sprite_frame]
	
func exit():
	player.change_color_to_power(Color.GRAY)
	player.trajectory.default_color = Color.GRAY

func update(_delta):
	#if not player.can_shoot:
		#return
	if Input.is_action_just_released(player.keyboard_profile + "shot") or player.wants_shoot:
		player.shoot.emit()
		player.wants_shoot = false
		player.user_input_component.timer_power.stop()
		if Globals.playable_missiles_nodes[player.current_missile].consumable:
			return
		transition.emit(self, "idle")

func update_physics(_delta):
	var direction = Input.get_axis(player.keyboard_profile + "left_move", player.keyboard_profile + "right_move")

	if direction > 0 and player.animated_sprite.flip_h:
		player.animated_sprite.flip_h = false
		player.flip_angle_horizontally()
	elif direction < 0 and not player.animated_sprite.flip_h:
		player.animated_sprite.flip_h = true
		player.flip_angle_horizontally()

	calculate_movement_speed(_delta, direction)
	
func calculate_movement_speed(_delta, direction):
	if player.stamina <= 0:
		direction = 0
	
	var max_movement = direction * player.SPEED_MOVEMENT
	var acceleration = lerp(player.velocity.x, direction * player.SPEED_MOVEMENT, _delta * player.ACCELERATION_MOVEMENT)
	
	if abs(max_movement) > abs(acceleration):
		player.velocity.x = acceleration
		#player.run_sfx.play()
		player.stamina -= abs(player.velocity.x)/1000
	else:
		var desacceleration = lerp(player.velocity.x, direction * player.SPEED_MOVEMENT, _delta * player.DESACCELERATION_MOVEMENT)
		player.velocity.x = desacceleration
	
