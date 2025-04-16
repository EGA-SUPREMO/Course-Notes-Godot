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
	if not Globals.playable_missiles_nodes[player.active_item_type][player.selectedItem].consumable:
		if Input.is_action_just_released(player.keyboard_profile + "shot") or player.wants_shoot:
			player.shoot.emit()
			player.wants_shoot = false
			player.user_input_component.timer_power.stop()
			transition.emit(self, "idle")
