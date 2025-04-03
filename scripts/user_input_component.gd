extends Node
class_name UserInputComponent

var timer_angle := Timer.new()
var timer_power_fast_mode := Timer.new()
var player: Player

var timer_power := Timer.new()

func _ready() -> void:
	timer_power.wait_time = 0.5
	timer_power.one_shot = true
	timer_power.timeout.connect(on_power_timeout)
	add_child(timer_power)

	timer_angle.timeout.connect(on_angle_timeout)
	timer_angle.one_shot = true
	timer_power_fast_mode.timeout.connect(on_power_fast_mode_timeout)
	timer_power_fast_mode.one_shot = true
	add_child(timer_angle)
	add_child(timer_power_fast_mode)

func update_user_input(_delta: float) -> void:
	if player.wants_shoot:
		return
	
	if Input.is_action_just_pressed(player.keyboard_profile + "shot"):
		timer_power.start()
	
	if Input.is_action_just_pressed(player.keyboard_profile + "lower_angle"):
		#player.angle -= 1
		player.change_angle(player.angle - 1)
		timer_angle.start(0.25)
	if Input.is_action_just_pressed(player.keyboard_profile + "increase_angle"):
		#player.angle += 1
		player.change_angle(player.angle + 1)
		timer_angle.start(0.25)
	
	#if Input.is_action_just_pressed(player.keyboard_profile + "decrease_power"):
		#player.missile_power -= 10
		#timer_power_fast_mode.start(0.25)
	#if Input.is_action_just_pressed(player.keyboard_profile + "increase_power"):
		#player.missile_power += 10
		#timer_power_fast_mode.start(0.25)
	#
	if Input.is_action_just_pressed(player.keyboard_profile + "previous_missile"):
		player.change_current_missile_to_previous_missile_in_inventory()
	if Input.is_action_just_pressed(player.keyboard_profile + "next_missile"):
		player.change_current_missile_to_next_missile_in_inventory()

func on_power_fast_mode_timeout():
	timer_power_fast_mode.wait_time = 0.05
	if Input.is_action_pressed(player.keyboard_profile + "decrease_power"):
		player.missile_power -= 10
		timer_power_fast_mode.start()
	if Input.is_action_pressed(player.keyboard_profile + "increase_power"):
		player.missile_power += 10
		timer_power_fast_mode.start()
	
func on_power_timeout():
	var sign:= 1
	if Input.is_action_pressed(player.keyboard_profile + "wildcard_key"):
		sign = -1
	if Input.is_action_pressed(player.keyboard_profile + "shot"):
		player.missile_power += 10 * sign
		timer_power.start()

func on_angle_timeout():
	timer_angle.wait_time = 0.02
	if Input.is_action_pressed(player.keyboard_profile + "increase_angle"):
		#player.angle += 3
		player.change_angle(player.angle + 3)
		timer_angle.start()
	if Input.is_action_pressed(player.keyboard_profile + "lower_angle"):
		#player.angle -= 3
		player.change_angle(player.angle - 3)
		timer_angle.start()
