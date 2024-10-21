extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_quick_match_pressed() -> void:
	var game = load("res://scene/main.tscn")
	game.instantiate()
	print(game.get_local_scene())
	#get_tree().change_scene_to_file(game)
	get_tree().change_scene_to_packed(game)
