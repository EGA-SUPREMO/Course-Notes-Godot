extends Node
class_name UserInputComponent

func update_user_input(player: Player, delta: float) -> void:
	var direction_angle_changed = Input.get_axis(player.keyboard_profile + "increase_angle", player.keyboard_profile + "lower_angle")
	if direction_angle_changed > 0:
		player.angle -= 2 * delta
	elif direction_angle_changed < 0:
		player.angle += 2 * delta
	
	var direction_power_changed = Input.get_axis(player.keyboard_profile + "increase_power", player.keyboard_profile + "decrease_power")
	if direction_power_changed < 0:
		player.missile_power += 100 * delta
	elif direction_power_changed > 0:
		player.missile_power -= 100 * delta
