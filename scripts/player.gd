extends CharacterBody2D
class_name Player

@onready var animated_sprite = $AnimatedSprite2D
@onready var state_machine: Node = $StateMachine
@onready var hurt_sfx: AudioStreamPlayer2D = $HurtSFX
@onready var label: Label = $Label

@export var missile_power := 50
@export var keyboard_profile: String
var missile
signal shoot

@onready var player = $"."
@onready var hud = $HUD
@onready var children_count = $HUD.get_child_count()

#var damage = 15
var HP:= 100.0
var money := 5000
const MONEY_MULTIPLIER = 50
const SPEED_MOVEMENT = 100.0
const ACCELERATION_MOVEMENT = 5.0
const DESACCELERATION_MOVEMENT = ACCELERATION_MOVEMENT * 2.0

@export var human: bool
@onready var user_input_component: UserInputComponent = $UserInputComponent

@export var angle := 0.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	for i in range(children_count):
		var child = hud.get_child(i)
		var scale_factor = (i + 1) / float(children_count)
		child.scale = Vector2(0.4, 0.4)
		child.scale *= scale_factor
		child.position.x = 64
		child.position.x *= scale_factor*scale_factor
		
	if human:
		state_machine.current_state.transition.emit(state_machine.current_state, "attacking")
		
		
func _process(delta):
	label.text = "$: " + str(money) + "\nHp: " + str(HP)
	
	if human:# change something like state machine when IA is fully implemented
		user_input_component.update_user_input(self, delta)
	
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
	

func calculate_quadratic_damage(target_position: Vector2, damage: float) -> float:
	var distance = target_position.distance_to(position)
	var explosion_radius = damage * 2
	
	if distance > explosion_radius:
		return 0  # No damage outside the explosion radius
	
	return damage * (1 - pow(distance / explosion_radius, 2))
	
func destroy(missile):
	var damage = calculate_quadratic_damage(missile.global_position, missile.damage)
	if damage>0:
		HP -= damage
		var sign = ( -1 if missile.who_shoot == self else 1 )
		missile.who_shoot.money += damage * sign * MONEY_MULTIPLIER
		
		hurt_sfx.stream = load("res://assets/sounds/hurt_"+ str(randi_range(1, 3)) +".wav")# TODO is this loaded everytime theres a explotion?, is so change that with an array or smth smh
		hurt_sfx.pitch_scale = randf() + 0.5
		hurt_sfx.play()

	if HP < 0:
		queue_free()
