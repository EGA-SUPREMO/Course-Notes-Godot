extends Node
class_name UserInputComponent

var timer_angle := Timer.new()
var timer_power := Timer.new()
var player: Player

func _ready() -> void:
	timer_angle.timeout.connect(on_angle_timeout)
	timer_angle.one_shot = true
	timer_power.timeout.connect(on_power_timeout)
	timer_power.one_shot = true
	add_child(timer_angle)
	add_child(timer_power)

func update_user_input(_delta: float) -> void:
	if player.wants_shoot:
		return
	if Input.is_action_just_pressed(player.keyboard_profile + "lower_angle"):
		player.angle -= 3
		timer_angle.start(0.25)
	if Input.is_action_just_pressed(player.keyboard_profile + "increase_angle"):
		player.angle += 3
		timer_angle.start(0.25)
	
	if Input.is_action_just_pressed(player.keyboard_profile + "decrease_power"):
		player.missile_power -= 10
		timer_power.start(0.25)
	if Input.is_action_just_pressed(player.keyboard_profile + "increase_power"):
		player.missile_power += 10
		timer_power.start(0.25)
	
	if Input.is_action_just_pressed(player.keyboard_profile + "previous_missile"):
		player.change_current_missile_to_previous_missile_in_inventory()
	if Input.is_action_just_pressed(player.keyboard_profile + "next_missile"):
		player.change_current_missile_to_next_missile_in_inventory()

func on_power_timeout():
	timer_power.wait_time = 0.10
	if Input.is_action_pressed(player.keyboard_profile + "decrease_power"):
		player.missile_power -= 10
		timer_power.start()
	if Input.is_action_pressed(player.keyboard_profile + "increase_power"):
		player.missile_power += 10
		timer_power.start()
	
func on_angle_timeout():
	timer_angle.wait_time = 0.03
	if Input.is_action_pressed(player.keyboard_profile + "increase_angle"):
		player.angle += 3
		timer_angle.start()
	if Input.is_action_pressed(player.keyboard_profile + "lower_angle"):
		player.angle -= 3
		timer_angle.start()
