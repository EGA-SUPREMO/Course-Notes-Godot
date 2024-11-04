extends Node

var players: Node
var number_players:= 3

func _ready() -> void:
	players = Node.new()
	players.add_to_group("destructibles")
	
	for i in range(number_players):
		var player = preload("res://scene/player.tscn").instantiate()
		player.human = true
		player.resource_sprite_frame = i
		player.id = i
		player.position.x = randi_range(0, 600)
		player.position.y = randi_range(-100, -200)
		players.add_child(player)
	
	players.get_child(2).human = false
	
func prepare_new_match():
	for player in players.get_children():
		player.position.x = randi_range(0, 600)
		player.position.y = randi_range(-200, -300)
		player.HP = player.max_hp
		player.stamina = player.max_stamina
		player.state_machine.current_state.next_turn()
		
func sort_players_node_by_id():
	var sorted_nodes := players.get_children()

	sorted_nodes.sort_custom(
		func(a: Player, b: Player): return a.id < b.id
	)

	for node in players.get_children():
		players.remove_child(node)

	for node in sorted_nodes:
		players.add_child(node)
