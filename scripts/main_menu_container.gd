extends Control

var credits_activated := false
var credits_panel = preload("res://scene/UI/credits.tscn").instantiate()
@onready var center_container: CenterContainer = $CenterContainer

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/play_menu.tscn")

func _on_quick_match_pressed() -> void:
	MatchManager.number_players = randi_range(2, 5)
	MatchManager.clean_players()
	get_tree().change_scene_to_file("res://scene/main.tscn")


func _on_create_match_pressed() -> void:
	var create_menu_node = preload("res://scene/menus/create_match_menu.tscn").instantiate()
	add_child(create_menu_node)
	
func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_credits_pressed() -> void:
	center_container.add_child(credits_panel)
	
func _on_credits_exit_press():
	credits_activated = false
	center_container.remove_child(credits_panel)
