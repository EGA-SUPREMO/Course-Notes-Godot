extends Control

var credits_activated := false
var credits_panel = preload("res://scene/UI/credits.tscn").instantiate()
@onready var center_container: CenterContainer = $CenterContainer

func _ready() -> void:
	credits_panel.get_child(0).get_child(1).connect("pressed", _on_credits_exit_press)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/play_menu.tscn")

func _on_quick_match_pressed() -> void:
	MatchManager.number_players = randi_range(2, 5)
	MatchManager.create_players()
	get_tree().change_scene_to_file("res://scene/main.tscn")


func _on_create_match_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/menus/create_match_menu.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_credits_pressed() -> void:
	if credits_activated:
		center_container.remove_child(credits_panel)
	else:
		center_container.add_child(credits_panel)
	credits_activated = !credits_activated

func _on_credits_exit_press():
	credits_activated = false
	center_container.remove_child(credits_panel)
