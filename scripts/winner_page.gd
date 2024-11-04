extends Control

@onready var h_box_container: HBoxContainer = $VBoxContainer/HBoxContainer
@onready var sub_viewport: SubViewport = $VBoxContainer/HBoxContainer/SubViewportContainer/SubViewport
@onready var first_place_label: RichTextLabel = $VBoxContainer/FirstPlaceLabel

var players_sorted: Array

func _ready() -> void:
	
	first_place_label.custom_minimum_size = Vector2(200, 70)
	
	for player in MatchManager.players.get_children():
		players_sorted.append(player)
		MatchManager.players.remove_child(player)
	
	players_sorted.sort_custom(sort_players_by_win_count)
	var i:= 0
	for player in players_sorted:
		i += 1
		
		first_place_label.text += str(i) + ". place: " + player.name + "\nWins: " + str(player.win_count) + "\nDamage done: " + str(player.damage_done)
		
		var label = first_place_label.duplicate(0)
		label.text = str(i) + ". place: " + player.name + "\nWins: " + str(player.win_count) + "\nDamage done: " + str(player.damage_done)
		label.visible = true
		player.position = Vector2(70 + i*70, 0)
		
		label.position -= Vector2(0, 400 - i*80)
		sub_viewport.add_child(player)
		#h_box_container.add_child(first_place_label)
		player.add_child(label)
	

func sort_players_by_win_count(a: Player, b: Player) -> bool:
	if a.win_count > b.win_count:
		return true
	if a.win_count < b.win_count:
		return false
	if a.damage_done > b.damage_done:
		return true
	return false


func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/main_menu_container.tscn")
	# do stuff to reset everything TODO
