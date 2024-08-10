extends Node2D

signal destroy
#@onready var destructible = $Destructible
var last_misil#borrar, codigo feo
var scene_missile = preload("res://scene/missile.tscn")
@onready var timer = $Timer
@onready var terrain = $Terrain
@onready var camera_2d = $player/Camera2D

@onready var collision_polygon_2d = $RigidBody2D/CollisionPolygon2D
@onready var collision_polygon_2d2 = $RigidBody2D2/CollisionPolygon2D
@onready var rigid_body_2d = $RigidBody2D
@onready var rigid_body_2d2 = $RigidBody2D2


func _ready():
	rigid_body_2d.global_position = Vector2(160, -100)
	rigid_body_2d2.global_position = Vector2(-1000, -1000)
	collision_polygon_2d.polygon = PackedVector2Array(
		[Vector2(30, 20), Vector2(30, 10), Vector2(20, 0), Vector2(10, 10)])
	collision_polygon_2d2.polygon = PackedVector2Array(
		[Vector2(1030, 1020), Vector2(1030, 1010), Vector2(1020, 1000), Vector2(1010, 1010)])
	rigid_body_2d.center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_CUSTOM
	rigid_body_2d2.center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_CUSTOM
	rigid_body_2d.center_of_mass = -terrain.calculate_centroid(collision_polygon_2d.polygon)
	rigid_body_2d2.center_of_mass = -terrain.calculate_centroid(collision_polygon_2d2.polygon)

func _process(delta):
	if Input.is_action_pressed("reduce_zoom"):
		camera_2d.zoom.x += 0.5 * delta
		camera_2d.zoom.y += 0.5 * delta
	if Input.is_action_pressed("increase_zoom"):
		camera_2d.zoom.x -= 0.5 * delta
		camera_2d.zoom.y -= 0.5 * delta
		
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		terrain.clip(terrain.create_circle_radious_polygon(
			get_global_mouse_position(), $player.damage))	
	
		
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
		last_misil.global_position, $player.damage))
	print("boom3")


func _on_timer_timeout():
	on_destroy()
