extends Node2D

signal destroy
#@onready var destructible = $Destructible
var last_misil#borrar, codigo feo
var scene_missile = preload("res://scene/missile.tscn")
@onready var timer = $Timer
@onready var terrain = $Terrain
@onready var camera_2d = $Camera2D
@onready var rigid_body_2d = $RigidBody2D
@onready var collision_polygon_2d = $RigidBody2D/CollisionPolygon2D

func _ready():
	rigid_body_2d.center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_CUSTOM
	rigid_body_2d.center_of_mass = terrain.get_polygon_center(collision_polygon_2d.polygon)
	print(terrain.get_polygon_center(collision_polygon_2d.polygon))
	print(terrain.calculate_centroid(collision_polygon_2d.polygon))


func _process(delta):
	if Input.is_action_pressed("reduce_zoom"):
		camera_2d.zoom.x += 0.5 * delta
		camera_2d.zoom.y += 0.5 * delta
	if Input.is_action_pressed("increase_zoom"):
		camera_2d.zoom.x -= 0.5 * delta
		camera_2d.zoom.y -= 0.5 * delta
		
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		terrain.clip(terrain.create_circle_radious_polygon(
			get_global_mouse_position(), $player.damage), terrain.global_position)	
	
		
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
	terrain.clip(terrain.create_circle_radious_polygon(
		last_misil.global_position, $player.damage),
		terrain.global_position)
	print("boom3")


func _on_timer_timeout():
	on_destroy()
