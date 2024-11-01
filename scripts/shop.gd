extends Control

@onready var missiles: HBoxContainer = $PanelContainer/VBoxContainer/Missiles
@onready var traits: HBoxContainer = $PanelContainer/VBoxContainer/Traits
@onready var next_match_button: Button = $PanelContainer/VBoxContainer/NextMatch
@onready var progress_bar: ProgressBar = $PanelContainer/VBoxContainer/ProgressBar

@onready var fivebomb: TextureButton = $PanelContainer/VBoxContainer/Missiles/Fivebomb
@onready var hotshower: TextureButton = $PanelContainer/VBoxContainer/Missiles/Hotshower
@onready var nuclear: TextureButton = $PanelContainer/VBoxContainer/Missiles/Nuclear

@onready var enderpearl: TextureButton = $PanelContainer/VBoxContainer/Missiles/Consumables/Enderpearl
@onready var regenaration: TextureButton = $PanelContainer/VBoxContainer/Missiles/Consumables/Regeneration

@onready var hp: TextureButton = $PanelContainer/VBoxContainer/Traits/HP
@onready var movement_speed: TextureButton = $PanelContainer/VBoxContainer/Traits/MovementSpeed
@onready var stamina: TextureButton = $PanelContainer/VBoxContainer/Traits/Stamina

@onready var consumables: HBoxContainer = $PanelContainer/VBoxContainer/Missiles/Consumables
@onready var selector: Control = $Selector
@onready var selectors: Control = $Selectors

@onready var fail_buy_sfx: AudioStreamPlayer = $FailBuySFX
@onready var buy_sfx: AudioStreamPlayer = $BuySFX
@onready var movethis_to_global: AudioStreamPlayer = $MovethisToGlobal

var money_player: Label
var current_amount_label: Label

var labels: Array

var list_labels_selector: Array

var navigable_items: Array
var current_item_selected: Array
var player_selected_next_match: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	money_player = Label.new()
	current_amount_label = Label.new()
	
	progress_bar.value = Globals.current_match_count * 10
	
	for missile in missiles.get_children():
		if missile is not VSeparator and missile is not HBoxContainer:
			navigable_items.append(missile)
	for consumable in consumables.get_children():
		navigable_items.append(consumable)
	for current in traits.get_children():
		if current.name != "Ignore":
			navigable_items.append(current)
	navigable_items.append(next_match_button)
	
	create_selectors()
	
	for i in range(MatchManager.number_players):
		update_inventory(i)
	
func create_selectors():
	var selector_player: Array
	for player in range(MatchManager.number_players):
		current_item_selected.append(0)
		labels.append([])
		player_selected_next_match.append(false)
		list_labels_selector.append(Array())
		selector_player.append(selector.duplicate(0))
		for container in selector_player[-1].get_children():
			for item in container.get_children():
				list_labels_selector[player].append(item)
				item.z_index = -1000
				item.get_children()[0].color = Globals.colors_by_player[player]
	var number_labels_step = floori(12.0/MatchManager.number_players)
	
	for i in range(0, MatchManager.number_players):
		for j in range(i * number_labels_step, number_labels_step * (i + 1)):
			var local_counter = j - i * number_labels_step
			match local_counter:
				0:
					var label = money_player.duplicate(0)
					label.z_index = 1001
					label.text = "$" + str(MatchManager.players.get_children()[i].money)
					label.add_theme_color_override("font_color", Color.BLACK)
					list_labels_selector[i][j].add_child(label)
					
					labels[i].append(label)
				1:
					var label = current_amount_label.duplicate(0)
					label.z_index = 1001
					label.position.x += 15
					label.text = "0"
					label.add_theme_color_override("font_color", Color.BLACK)
					list_labels_selector[i][j].add_child(label)
					labels[i].append(label)
			list_labels_selector[i][j].z_index = 1000
			list_labels_selector[i][j].name = "player " + str(i) + ", " + str(j)
			
		selector_player[i].visible = true
		selectors.add_child(selector_player[i])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for i in range(MatchManager.number_players):
		if not MatchManager.players.get_children()[i].human:
			player_selected_next_match[i] = true# cambiar a algo mas natural, ej que mueva el selector a donde es
			current_item_selected[i] = 8
			#movethis_to_global.play()
			selectors.get_children()[i].global_position = navigable_items[current_item_selected[i]].global_position
			continue
		
		if player_selected_next_match[i]:
			continue
		if Input.is_action_just_pressed(MatchManager.players.get_children()[i].keyboard_profile + "left_move"):
			current_item_selected[i] -= 1
			if current_item_selected[i] <= -1:
				current_item_selected[i] = navigable_items.size() - 1
			
			#movethis_to_global.pitch_scale = 0.75 + float(current_item_selected[i])/navigable_items.size()/4
			movethis_to_global.play()
			update_inventory(i)
			
		if Input.is_action_just_pressed(MatchManager.players.get_children()[i].keyboard_profile + "right_move"):
			current_item_selected[i] += 1
			if current_item_selected[i] >= navigable_items.size():
				current_item_selected[i] = 0
			#movethis_to_global.pitch_scale = 0.75 + float(current_item_selected[i])/navigable_items.size()/4
			movethis_to_global.play()
			update_inventory(i)
			
		selectors.get_children()[i].global_position = navigable_items[current_item_selected[i]].global_position
		
		if Input.is_action_just_pressed(MatchManager.players.get_children()[i].keyboard_profile + "shot"):
			match navigable_items[current_item_selected[i]]:
				next_match_button:
					begin_next_match(i)
				hp:
					if buy(i, 10000):
						MatchManager.players.get_children()[i].max_hp *= 1.1
						update_inventory(i)
				movement_speed:
					if buy(i, 7000):
						MatchManager.players.get_children()[i].SPEED_MOVEMENT += 10
						update_inventory(i)
				stamina:
					if buy(i, 3000):
						MatchManager.players.get_children()[i].max_stamina += 100
						update_inventory(i)
				_:
					for j in range(Globals.playable_missiles_nodes.size()):
						if Globals.playable_missiles_nodes[j].name == navigable_items[current_item_selected[i]].name:
							buy_missile(i, j)

func begin_next_match(i):
	player_selected_next_match[i] = true
	for j in range(MatchManager.number_players):
		if not player_selected_next_match[j]:
			return
	MatchManager.call_deferred("prepare_new_match")
	# do stuff to preprare netx match? otherwise use oneline
	get_tree().change_scene_to_file("res://scene/main.tscn")
	
func buy(player_id: int, price: int) -> bool:
	var player = MatchManager.players.get_children()[player_id]
	if player.money >= price:
		player.money -= price
		buy_sfx.play()
		labels[player_id][0].text = "$" + str(player.money)
		
		return true
	fail_buy_sfx.play()
	return false
					
func buy_missile(player_id: int, missile_id: int) -> void:
	var player = MatchManager.players.get_children()[player_id]
	if player.money >= Globals.playable_missiles_nodes[missile_id].price:
		player.money -= Globals.playable_missiles_nodes[missile_id].price
		player.inventory[missile_id] += 1
		buy_sfx.play()
		labels[player_id][0].text = "$" + str(player.money)
		update_inventory(player_id)
		return
	fail_buy_sfx.play()

func update_inventory(player_id: int) -> void:
	var current_player = MatchManager.players.get_children()[player_id]
	var item = current_item_selected[player_id]
	
	match current_item_selected[player_id]:
		0, 1, 2:
			labels[player_id][1].text = str(current_player.inventory[item])
		5:
			labels[player_id][1].text = str(current_player.max_hp)
		6:
			labels[player_id][1].text = str(current_player.SPEED_MOVEMENT)
		7:
			labels[player_id][1].text = str(current_player.max_stamina)
		_:
			labels[player_id][1].text = ""
