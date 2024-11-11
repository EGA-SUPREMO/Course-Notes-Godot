extends Control

@onready var player_texture_1: TextureRect = $PlayerTexture_1
@onready var player_container: HBoxContainer = $VBoxContainer/HBoxContainer/PlayerContainer

var players_textures = [preload("res://assets/sprites/players/Zecretary-1.png"),
preload("res://assets/sprites/players/Pemaloe-1.png"),
preload("res://assets/sprites/players/Merakyat-1.png"),
preload("res://assets/sprites/Risuner-1.png"),
preload("res://assets/sprites/players/Moonafic-1.png")
]

func _ready() -> void:
	for i in range(2):
		create_players_textures()
		player_container.get_child(i).get_child(1).disabled = true
	
func _process(delta: float) -> void:
	pass


func create_players_textures():
	if player_container.get_child_count() > 4:
		return
	var player_texture = player_texture_1.duplicate(0)
	player_texture.texture = players_textures[player_container.get_child_count()]
	player_texture.get_child(1).connect("pressed", _on_remove_player_pressed.bind(player_texture.get_child(1)))
	player_texture.get_child(1).disabled = false
	player_texture.visible = true
	player_container.add_child(player_texture)
	

func _on_add_player_button_pressed() -> void:
	MatchManager.number_players += 1
	create_players_textures()


func _on_remove_player_pressed(node: Node) -> void:
	player_container.remove_child(node.get_parent())
	
