extends Node

var players: Node
var number_players:= 3

func _ready() -> void:
	players = Node.new()
	players.add_to_group("destructibles")
	
	for i in range(number_players):
		var player = preload("res://scene/player.tscn").instantiate()
		player.human = true
		player.keyboard_profile = "player_" + str(i + 1) + "_"
		player.position.x = randi_range(0, 600)
		player.position.y = randi_range(-100, -200)
		players.add_child(player)
	
	players.get_child(2).human = false
	
func prepare_new_match():
	#players.get_child(2).animated_sprite.sprite_frames = preload("res://scene/player_risu.tres")

	for player in players.get_children():
		print(player)
		player.position.x = randi_range(0, 600)
		player.position.y = randi_range(-100, -200)
		player.HP = player.max_hp
		player.stamina = player.max_stamina
		player.state_machine.current_state.next_turn()
		
