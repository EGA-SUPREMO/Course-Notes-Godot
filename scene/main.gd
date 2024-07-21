extends Node2D

signal destroy
#@onready var destructible = $Destructible
var last_misil#borrar, codigo feo
var scene_missile = preload("res://scene/missile.tscn")
@onready var timer = $Timer
@onready var terrain = $Terrain

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
	last_misil = missile
	timer.start()
	#missile.connect("explosion", on_destroy(missile.position, 30))
	add_child(missile)

func on_destroy():#position: Vector2, radious):
	print("boom")
	terrain.clip(terrain.create_circle_radious_polygon(last_misil.global_position, $player.damage), last_misil.global_position)
	print("boom3")


func _on_timer_timeout():
	on_destroy()
