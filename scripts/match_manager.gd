extends Node

var players: Node
var number_players:= 0
var image_ids = []
var is_human_bools = []

func _ready() -> void:
	players = Node.new()
	players.add_to_group("destructibles")
	image_ids = [0, 1, 2, 3, 4]
	is_human_bools = [true, false, false, false, false]
	
func clean_players():
	for player in players.get_children():
		players.remove_child(player)

	create_players()
	
func create_players(ids = [], human_bools = []) -> void:
	if !human_bools.size() and !ids.size():
		ids = image_ids
		human_bools = is_human_bools
	image_ids = ids
	is_human_bools = human_bools
	
	var player_positions = Globals.generate_random_positions(number_players, 250.0/number_players)
	player_positions.shuffle()
	
	for i in range(number_players):
		var player = preload("res://scene/player.tscn").instantiate()
		player.human = human_bools[i]
		player.resource_sprite_frame = ids[i]
		player.id = i
		player.position = player_positions[i]
		players.add_child(player)
		player.velocity = Vector2.ZERO#something random? ej they are flying couse explotion
	
	
func prepare_new_match():
	var player_positions = Globals.generate_random_positions(number_players, 250.0/number_players)
	player_positions.shuffle()
	
	for i in range(players.get_child_count()):
		var player = players.get_child(i)
		player.position = player_positions[i]
		player.HP = player.max_hp
		player.stamina = player.max_stamina
		player.state_machine.current_state.next_turn()
		
		player.velocity = Vector2.ZERO#something random? ej they are flying couse explotion
		player.wants_shoot = false
		#player.can_shoot = false
		#player.too_early_shoot_timer.start()
		
func sort_players_node_by_id():
	var sorted_nodes := players.get_children()

	sorted_nodes.sort_custom(
		func(a: Player, b: Player): return a.id < b.id
	)

	for node in players.get_children():
		players.remove_child(node)

	for node in sorted_nodes:
		players.add_child(node)
