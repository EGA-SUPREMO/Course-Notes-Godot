extends Node2D

var scene_missile = preload("res://scene/missile.tscn")

func _ready():
	pass # Replace with function body.


func _process(delta):
	pass
func _on_player_shoot():
	var missile = scene_missile.instantiate()
	missile.add_to_group("missile")
	missile.rotation = $player.angle + PI / 2
	missile.position = $player/HUD.global_position
	#print($player.global_position)
	var direction = Vector2(cos($player.angle), sin($player.angle))
	missile.apply_impulse(direction * $player.missile_power * 15, Vector2.ZERO)
		
	add_child(missile)
