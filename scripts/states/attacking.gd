extends State
class_name Attacking

@export var player: CharacterBody2D
var timer_power := Timer.new()

func _ready() -> void:
	timer_power.wait_time = 0.5
	timer_power.one_shot = true
	timer_power.timeout.connect(on_power_timeout)
	add_child(timer_power)

func enter():
	if player.trajectory:
		player.change_color_to_power(Globals.colors_by_player[player.resource_sprite_frame])
		player.trajectory.default_color = Globals.colors_by_player[player.resource_sprite_frame]
	
func exit():
	player.change_color_to_power(Color.GRAY)
	player.trajectory.default_color = Color.GRAY

func update(_delta):
	if Input.is_action_just_released(player.keyboard_profile + "shot") or player.wants_shoot:
		player.shoot.emit()
		player.wants_shoot = false
		timer_power.stop()
		#first_time_pressing_shoot = true
		if Globals.playable_missiles_nodes[player.current_missile].consumable:
			return
		transition.emit(self, "idle")

func update_physics(_delta):
	if Input.is_action_just_pressed(player.keyboard_profile + "shot"):
		
		timer_power.start()
	
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
	
#var first_time_pressing_shoot = true
func on_power_timeout():
	#if first_time_pressing_shoot:
		#player.missile_power = 0
		#first_time_pressing_shoot = false
		#timer_power.start()
		#return
	var sign:= 1
	if Input.is_action_pressed(player.keyboard_profile + "wildcard_key"):
		sign = -1
	if Input.is_action_pressed(player.keyboard_profile + "shot"):
		player.missile_power += 10 * sign
		timer_power.start()
