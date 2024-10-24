extends Node
class_name UserInputComponent

func update_user_input(player: Player, delta: float) -> void:
	if Input.is_action_just_released(player.keyboard_profile + "lower_angle"):
		player.angle -= 3
	if Input.is_action_just_released(player.keyboard_profile + "increase_angle"):
		player.angle += 3
	
	if Input.is_action_just_released(player.keyboard_profile + "decrease_power"):
		player.missile_power -= 10
	if Input.is_action_just_released(player.keyboard_profile + "increase_power"):
		player.missile_power += 10
	
	if Input.is_action_just_released(player.keyboard_profile + "previous_missile"):
		player.change_current_missile_to_previous_missile_in_inventory()
	if Input.is_action_just_released(player.keyboard_profile + "next_missile"):
		player.change_current_missile_to_next_missile_in_inventory()
