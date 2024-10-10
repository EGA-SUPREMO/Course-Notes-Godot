extends CharacterBody2D
class_name Player

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite = $AnimatedSprite2D
@onready var state_machine: Node = $StateMachine
@onready var hurt_sfx: AudioStreamPlayer2D = $HurtSFX
@onready var label: Label = $Label

@export var missile_power := 50
@export var keyboard_profile: String
signal shoot
signal death


var current_missile:= 0
var inventory
var text_temp : String
@onready var player = $"."
@onready var hud = $HUD
@onready var children_count = $HUD.get_child_count()
@onready var monitors: Node2D = $Monitors


var HP:= 100.0:
	set(value):
		if HP > value:
			hurt_sfx.stream = load("res://assets/sounds/hurt_"+ str(randi_range(1, 3)) +".wav")# TODO is this loaded everytime theres a explotion?, is so change that with an array or smth smh
			hurt_sfx.pitch_scale = randf() + 0.5
			hurt_sfx.play()
		HP = value
		if HP <= 0:
			death.emit()
	get():
		return roundi(HP)
			
var money := 5000
const MONEY_MULTIPLIER = 50
const SPEED_MOVEMENT = 100.0
const ACCELERATION_MOVEMENT = 5.0
const DESACCELERATION_MOVEMENT = ACCELERATION_MOVEMENT * 2.0
const FORCE_MULTIPLIER_TO_PLAYERS = 1

@export var human: bool
@onready var user_input_component: UserInputComponent = $UserInputComponent

@export var angle := 0.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var mass

func _ready():
	for collision_side in monitors.get_children():
		collision_side.connect("body_entered", _on_area_2d_body_entered)
		collision_side.collision_mask = 6
	mass = (collision_shape.shape.radius * 2) * collision_shape.shape.height
	
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
	label.text = "$: " + str(money) + "\nHp: " + str(HP) + text_temp
	text_temp = ""
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
	var distance = Globals.get_closest_distance_to_shape(collision_shape, target_position)
	var explosion_radius = damage * 2
	
	if distance > explosion_radius:
		return 0  # No damage outside the explosion radius
	
	return damage * (1 - pow(distance / explosion_radius, 2))
	
func destroy(exploded_missile):
	var damage = calculate_quadratic_damage(exploded_missile.global_position, exploded_missile.damage)
	if damage>0:
		HP -= damage
		var sign = ( -1 if exploded_missile.who_shoot == self else 1 )
		exploded_missile.who_shoot.money += damage * sign * MONEY_MULTIPLIER
		
		var direction: Vector2 = player.global_position - exploded_missile.global_position
		direction = direction.normalized()
		var impulse = Global.calculate_strength_knockback(player.global_position,
				exploded_missile.position, damage*FORCE_MULTIPLIER_TO_PLAYERS, mass) * 2
		player.velocity += impulse.clampf(-200, 200) * direction


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D or body is Missile:
		return
	var left_overlapping = false
	var right_overlapping = false
	var top_overlapping = false
	var bottom_overlapping = false
	
	for collision_side in monitors.get_children():
		if collision_side.has_overlapping_bodies():
			match collision_side.name:
				"MonitorLeft":
					left_overlapping = true
				"MonitorRight":
					right_overlapping = true
				"MonitorTop":
					top_overlapping = true
				"MonitorBottom":
					bottom_overlapping = true
		
	if (left_overlapping and right_overlapping) or (top_overlapping and bottom_overlapping):
		#text_temp += "\n " + str(left_overlapping)
		#text_temp += "\n " + str(right_overlapping)
		#text_temp += "\n " + str(top_overlapping)
		#text_temp += "\n " + str(bottom_overlapping)
		#print(str(player) + text_temp)
		apply_squish_damage(body)

func apply_squish_damage(_body):
	if _body is StaticBody2D:
		return
	var angular_force = _body.angular_velocity * _body.mass
	var linear_force = _body.linear_velocity.length() * _body.mass
	var total_force = angular_force + linear_force# TODO este metodo le falta chicha
	
	HP -= total_force/20000
