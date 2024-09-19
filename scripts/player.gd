extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var state_machine: Node = $StateMachine

@export var missile_power := 50
@export var keyboard_profile: String
var missile
signal shoot

@onready var player = $"."
@onready var hud = $HUD
@onready var children_count = $HUD.get_child_count()

var damage = 15
var HP:= 100.0
var money := 0

var scene_missile = preload("res://scene/missile.tscn")
@export var angle := 0.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	for i in range(children_count):
		var child = $HUD.get_child(i)
		var scale_factor = (i + 1) / float(children_count)
		child.scale = Vector2(0.4, 0.4)
		child.scale *= scale_factor
		child.position.x = 64
		child.position.x *= scale_factor*scale_factor
		
func _process(delta):
	var direction_angle_changed = Input.get_axis(keyboard_profile + "increase_angle", keyboard_profile + "lower_angle")
	if direction_angle_changed > 0:
		angle -= 2 * delta#aparentemente no se debe usar cuando algo ocurre con el tiempo, no cuando ocurre inmediatamente, borrar el delta time y ver si cambia 2 frams vs 60 frams
	elif direction_angle_changed < 0:
		angle += 2 * delta
	
	var direction_power_changed = Input.get_axis(keyboard_profile + "increase_power", keyboard_profile + "decrease_power")
	if direction_power_changed < 0:
		damage += 50 * delta
		missile_power += 100 * delta#aparentemente no se debe usar cuando algo ocurre con el tiempo, no cuando ocurre inmediatamente, borrar el delta time y ver si cambia 2 frams vs 60 frams
	elif direction_power_changed > 0:
		damage -= 50 * delta
		missile_power -= 100 * delta
	
	set_percentage_visible_power(missile_power)
		
	hud.rotation = angle
	
func set_percentage_visible_power(power: int):
	var percentage = clamp(power, 0, 100)
	var num_true_items = int($HUD.get_child_count() * percentage / 100.0)
	
	for i in range(num_true_items):
		$HUD.get_children()[i].visible = true
	for i in range($HUD.get_child_count() - num_true_items):
		$HUD.get_children()[i + num_true_items].visible = false
	
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	move_and_slide()
	
func _on_player_shoot():
	missile = scene_missile.instantiate()
	missile.add_to_group("missile")
	missile.rotation = angle + PI / 2
	missile.position = $HUD.global_position
	var direction = Vector2(cos(angle), sin(angle))
	missile.apply_impulse(direction * missile_power * 15, Vector2.ZERO)
	missile.who_shoot = self
	shoot.emit()
