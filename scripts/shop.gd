extends Control

@onready var missiles: HBoxContainer = $PanelContainer/VBoxContainer/Missiles
@onready var traits: HBoxContainer = $PanelContainer/VBoxContainer/Traits
@onready var next_match_button: Button = $PanelContainer/VBoxContainer/NextMatch
@onready var progress_bar: ProgressBar = $PanelContainer/VBoxContainer/ProgressBar

@onready var hp: TextureButton = $PanelContainer/VBoxContainer/Traits/HP
@onready var movement_speed: TextureButton = $PanelContainer/VBoxContainer/Traits/MovementSpeed
@onready var stamina: TextureButton = $PanelContainer/VBoxContainer/Traits/Stamina

@onready var consumables: HBoxContainer = $PanelContainer/VBoxContainer/Missiles/Consumables
@onready var selector: Control = $PanelContainer/Selector
@onready var selectors: Control = $PanelContainer/Selectors

var list_labels_selector: Array

var navigable_items: Array
var current_item_selected: Array
var player_selected_next_match: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	progress_bar.value = Globals.current_match_count * 10
	for missile in missiles.get_children():
		if missile is not VSeparator and missile is not HBoxContainer:
			navigable_items.append(missile)
	for consumable in consumables.get_children():
		navigable_items.append(consumable)
	for current in traits.get_children():
		navigable_items.append(current)
	navigable_items.append(next_match_button)
	
	create_selectors()
	
func create_selectors():
	var selector_player: Array
	for player in range(MatchManager.number_players):
		current_item_selected.append(0)
		player_selected_next_match.append(false)
		list_labels_selector.append(Array())
		selector_player.append(selector.duplicate(0))
		for container in selector_player[-1].get_children():
			for item in container.get_children():
				list_labels_selector[player].append(item)
				#item.visible = false
				item.z_index = -1000
		
	var number_labels_step = floori(12.0/MatchManager.number_players)
	
	for i in range(0, MatchManager.number_players):
		for j in range(i * number_labels_step, number_labels_step * (i + 1)):
			#list_labels_selector[i][j].visible = true
			list_labels_selector[i][j].z_index = 1000
			list_labels_selector[i][j].name = "player " + str(i) + ", " + str(j)
			
		selector_player[i].visible = true
		selectors.add_child(selector_player[i])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for i in range(MatchManager.number_players):
		if not MatchManager.players.get_children()[i].human:
			continue
		if player_selected_next_match[i]:
			continue
		if Input.is_action_just_pressed(MatchManager.players.get_children()[i].keyboard_profile + "left_move"):
			current_item_selected[i] -= 1
			if current_item_selected[i] <= -1:
				current_item_selected[i] = navigable_items.size() - 1
		if Input.is_action_just_pressed(MatchManager.players.get_children()[i].keyboard_profile + "right_move"):
			current_item_selected[i] += 1
			if current_item_selected[i] >= navigable_items.size():
				current_item_selected[i] = 0
		
		selectors.get_children()[i].position = navigable_items[current_item_selected[i]].global_position
		
		if Input.is_action_just_pressed("ui_accept"):
			match navigable_items[current_item_selected[i]]:
				next_match_button:
					begin_next_match(i)
				hp:
					if buy(MatchManager.players.get_children()[i], 10000):
						MatchManager.players.get_children()[i].max_hp *= 1.1
						print(MatchManager.players.get_children()[i].max_hp)
				stamina:
					if buy(MatchManager.players.get_children()[i], 3000):
						MatchManager.players.get_children()[i].max_stamina += 100
						print(MatchManager.players.get_children()[i].max_stamina)
				
func begin_next_match(i):
	player_selected_next_match[i] = true
	for j in range(MatchManager.number_players):
		if not player_selected_next_match[j]:
			return
	MatchManager.call_deferred("prepare_new_match")
	# do stuff to preprare netx match? otherwise use oneline
	get_tree().change_scene_to_file("res://scene/main.tscn")
	
func buy(player: Player, price: int) -> bool:
	if player.money >= price:
		player.money -= price
		return true
	return false
					
