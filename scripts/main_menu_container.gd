extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/play_menu.tscn")

func _on_quick_match_pressed() -> void:
	MatchManager.number_players = randi_range(2, 5)
	MatchManager.create_players()
	get_tree().change_scene_to_file("res://scene/main.tscn")


func _on_create_match_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/menus/create_match_menu.tscn")
