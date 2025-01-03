extends State
class_name Attacking

@export var player: CharacterBody2D

func enter():
	player.call_deferred("change_color_to_power", Globals.colors_by_player[player.resource_sprite_frame])
	if player.trajectory:
		player.trajectory.default_color = Globals.colors_by_player[player.resource_sprite_frame]
	
func exit():
	player.change_color_to_power(Color.GRAY)
	player.trajectory.default_color = Color.GRAY

func update(_delta):
	if Input.is_action_just_pressed(player.keyboard_profile + "shot"):
		player.shoot.emit()
		if Globals.playable_missiles_nodes[player.current_missile].consumable:
			return
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
		#player.run_sfx.play()
		player.stamina -= abs(player.velocity.x)/1000
	else:
		var desacceleration = lerp(player.velocity.x, direction * player.SPEED_MOVEMENT, _delta * player.DESACCELERATION_MOVEMENT)
		player.velocity.x = desacceleration
	
