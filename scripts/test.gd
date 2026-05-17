extends Main


func next_turn():
	players_on_wait = true
	
	if players.get_child_count() <= 1 and not missiles.get_child_count():
		# next_round()
		pass
	
	for missile in missiles.get_children():
		if !missile.collision_shape_2d.disabled:
			return
	for player in players.get_children():
		if player.state_machine.current_state.name.to_lower()=="attacking" or player.state_machine.current_state.name.to_lower()=="ai_attacking":
			return
	
	if players_on_wait:
		for player in players.get_children():
			player.state_machine.current_state.next_turn()
