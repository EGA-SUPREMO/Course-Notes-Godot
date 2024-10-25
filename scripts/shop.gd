extends Control

@onready var missiles: HBoxContainer = $VBoxContainer/Missiles
@onready var traits: HBoxContainer = $VBoxContainer/Traits
@onready var next_match_button: Button = $VBoxContainer/NextMatch
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar

@onready var consumables: HBoxContainer = $VBoxContainer/Missiles/Consumables
@onready var selector: Control = $Selector
@onready var selectors: Control = $Selectors

var list_labels_selector: Array

var navigable_items: Array
var current_item_selected = 0

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
		list_labels_selector.append(Array())
		for container in selector.get_children():
			for item in container.get_children():
				list_labels_selector[player].append(item)
				item.visible = false
		selector_player.append(selector.duplicate(0))
		
	var number_labels_step = floori(12/MatchManager.number_players)
	print(number_labels_step)
	for i in range(0, MatchManager.number_players):
		for j in range(i * number_labels_step, number_labels_step * (i + 1)):
			print("player " + str(i) + ", selector: " + str(j))
			#selector_player.get_children()[0].get_children()[j - i * number_labels_step].visible = true
			list_labels_selector[i][j].visible = true
			print(list_labels_selector[i][j])
		selector_player[i].visible = true
		selectors.add_child(selector_player[i])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_left"):
		current_item_selected -= 1
		
		if current_item_selected <= -1:
			current_item_selected = navigable_items.size() - 1
	if Input.is_action_just_pressed("ui_right"):
		current_item_selected += 1
		if current_item_selected >= navigable_items.size():
			current_item_selected = 0
	
	selectors.get_children()[0].position = navigable_items[current_item_selected].global_position
	
	if Input.is_action_just_pressed("ui_accept"):
		if navigable_items[current_item_selected] == next_match_button:
			print(MatchManager.players.get_children())
			var game = load("res://scene/main.tscn")
			# do stuff to preprare netx match? otherwise use oneline
			get_tree().change_scene_to_packed(game)
