extends Node2D

@export var missile_power := 500
var scene_missile = preload("res://scene/missile.tscn")

func _ready():
	pass # Replace with function body.


func _process(delta):
	#label.text = "Angle " + str($player.angle + PI / 2) + "\nMISIL: " + str(get_tree().get_first_node_in_group("missile").rotation)
	pass
func _on_player_shoot():
	var missile = scene_missile.instantiate()
	missile.add_to_group("missile")
	missile.rotation = $player.angle + PI / 2
	missile.position = $player.global_position + Vector2(0, -19) # usar layers, no me gusta esa forma de hacer las cosas
	var direction = Vector2(cos($player.angle), sin($player.angle))
	missile.apply_impulse(direction * missile_power, Vector2.ZERO)
	
	add_child(missile)
