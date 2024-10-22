extends Control

@onready var missiles: HBoxContainer = $VBoxContainer/Missiles
@onready var traits: HBoxContainer = $VBoxContainer/Traits
@onready var next_match_button: Button = $VBoxContainer/NextMatch

@onready var consumables: HBoxContainer = $VBoxContainer/Missiles/Consumables
@onready var selector: Control = $Selector

var navigable_items: Array
var current_item_selected = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for missile in missiles.get_children():
		if missile is not VSeparator and missile is not HBoxContainer:
			navigable_items.append(missile)
	for consumable in consumables.get_children():
		navigable_items.append(consumable)
	for current in traits.get_children():
		navigable_items.append(current)
	navigable_items.append(next_match_button)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_left"):
		current_item_selected -= 1
		
		if current_item_selected <= -1:
			current_item_selected = navigable_items.size() - 1
	if Input.is_action_just_pressed("ui_right"):
		current_item_selected += 1
		if current_item_selected >= navigable_items.size():
			current_item_selected = 0
	
	selector.position = navigable_items[current_item_selected].global_position
	
	if Input.is_action_just_pressed("ui_accept"):
		if navigable_items[current_item_selected] == next_match_button:
			var game = load("res://scene/main.tscn")
			get_tree().change_scene_to_packed(game)
