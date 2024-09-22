extends Node
class_name UserInputComponent

func update_user_input(player: Player, delta: float) -> void:
	var direction_angle_changed = Input.get_axis(player.keyboard_profile + "lower_angle", player.keyboard_profile + "increase_angle")
	player.angle += 2 * delta * direction_angle_changed
	
	var direction_power_changed = Input.get_axis(player.keyboard_profile + "decrease_power", player.keyboard_profile + "increase_power")
	player.missile_power += 100 * delta * direction_power_changed
