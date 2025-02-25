extends Control
@onready var player_panel_1: Panel = $Panel
@onready var player_container: HBoxContainer = $MarginContainer/VBoxContainer/Panel/MarginContainer/MainPlayerContainer/PlayerContainer

var players_textures = [preload("res://assets/sprites/players/Zecretary-1.png"),
preload("res://assets/sprites/players/Pemaloe-1.png"),
preload("res://assets/sprites/players/Merakyat-1.png"),
preload("res://assets/sprites/Risuner-1.png"),
preload("res://assets/sprites/players/Moonafic-1.png")
]

var available_ids = [] # List of reusable IDs
var next_id = 0 # Next ID to use if no reusable IDs are available


func _ready() -> void:
	MatchManager.number_players = 0
	for i in range(2):
		create_players_textures()
		print(player_container.get_child(i).get_child(1))
		player_container.get_child(i).get_child(1).disabled = true
	
func _process(delta: float) -> void:
	pass


func create_players_textures():
	if player_container.get_child_count() > 4:
		return
	var image_id
	if available_ids.size() > 0:
		image_id = available_ids.pop_front() # Reuse an available ID
	else:
		image_id = next_id
		next_id += 1
	var player_panel := player_panel_1.duplicate(0)
	var player_texture := player_panel.get_child(0)
	player_texture.texture = players_textures[image_id]
	player_panel.get_child(2).connect("pressed", _on_remove_player_pressed.bind(player_panel.get_child(0)))
	player_panel.get_child(1).disabled = false
	player_panel.visible = true
	player_texture.set_meta("image_id", image_id)
	player_texture.set_meta("human", true)
	player_container.add_child(player_panel)
	MatchManager.number_players += 1

func _on_add_player_button_pressed() -> void:
	create_players_textures()


func _on_remove_player_pressed(player_texture_node: Node) -> void:
	player_container.remove_child(player_texture_node.get_parent())
	player_texture_node.queue_free()
	MatchManager.number_players -= 1
	var image_id = player_texture_node.get_parent().get_meta("image_id")
	available_ids.append(image_id)


func _on_start_match_pressed() -> void:
	var ids = []
	var human_bools = []
	for player_node in player_container.get_children():
		ids.append(player_node.get_child(0).get_meta("image_id"))
		human_bools.append(!player_node.get_child(1).button_pressed)
	MatchManager.create_players(ids, human_bools)
	get_tree().change_scene_to_file("res://scene/main.tscn")


func _on_back_pressed() -> void:
	get_parent().remove_child(self)
