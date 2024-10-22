extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_quick_match_pressed() -> void:
	var game = load("res://scene/main.tscn").instantiate()
	
	for i in range(1, 5):
		var new_player = Player.new()
		new_player.human = true
		new_player.keyboard_profile = "player_" + str(i) + "_"
		new_player.position = Vector2(randf_range(0, 200), randf_range(0, -200))
		game.get_node("Players").call_deferred("add_child", new_player)
		game.call_deferred("add_player", new_player)
	#print(game.get_children())
	print(game.get_children())
	
	#game.get_node("Players").get_children()[1].animated_sprite.sprite_frames = preload("res://scene/player_risu.tres")
	
	print(game.get_node("Players").get_children())
	print(game)
	#get_tree().root.add_child(game)
	#get_tree().unload_current_scene()
	#get_tree().current_scene = game
	#get_tree().current_scene.queue_free()
	var new_packed_scene = PackedScene.new()
	new_packed_scene.pack(game)

	# Now switch to the new PackedScene
	get_tree().change_scene_to_packed(new_packed_scene)
