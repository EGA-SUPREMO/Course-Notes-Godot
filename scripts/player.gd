extends CharacterBody2D
class_name Player

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite = $AnimatedSprite2D
@onready var state_machine: Node = $StateMachine
@onready var hurt_sfx: AudioStreamPlayer2D = $HurtSFX
@onready var label: Label = $Label
@onready var woosh_sfx: AudioStreamPlayer2D = $WooshSFX
@onready var run_sfx: AudioStreamPlayer2D = $RunSFX

@export var missile_power := 50:
	set(value):
		missile_power = clamp(value, 0, 100)
		if tap_sfx and trajectory and missile_power == value:
			tap_sfx.play()
			trajectory.update_trajectory(angle, missile_power)

@export var keyboard_profile: String
signal shoot
signal death


var current_missile:= 1
var inventory : Array
var stamina:= 500
var damage_done: int
var text_temp : String
@onready var player = $"."
@onready var hud = $HUD
@onready var monitors: Node2D = $Monitors
@onready var trajectory: Line2D = $Trajectory

var max_hp := 100.0
var max_stamina := 300
var HP:= max_hp:
	set(value):
		if HP > value:
			hurt_sfx.stream = load("res://assets/sounds/hurt_"+ str(randi_range(1, 3)) +".wav")# TODO is this loaded everytime theres a explotion?, is so change that with an array or smth smh
			hurt_sfx.pitch_scale = randf() + 0.5
			hurt_sfx.play()
		if value > max_hp:
			print("nono" + str(value))
			return
		HP = value
		if HP <= 0:
			death.emit()
	get():
		return roundi(HP)
			
var money := 10000:
	set(value):
		money = clamp(value, 0, INF)
const MONEY_MULTIPLIER = 50
var SPEED_MOVEMENT = 50.0
const ACCELERATION_MOVEMENT = 5.0
const DESACCELERATION_MOVEMENT = ACCELERATION_MOVEMENT * 2.0
const FORCE_MULTIPLIER_TO_PLAYERS = 1
const POWER_MULTIPLIER = 10

@export var resource_sprite_frame: int
@export var human: bool
@onready var user_input_component: UserInputComponent = $UserInputComponent
@onready var angle_number: Label = $HUD/AngleNumberLabel
var amount_power_sprites: int
@onready var power_label: Label = $HUD/PowerLabel
@onready var tap_sfx: AudioStreamPlayer2D = $TapSFX

@export var angle := 0.0:
	set(value):
		if tap_sfx and trajectory:
			trajectory.update_trajectory(value, missile_power)
			tap_sfx.play()
		if value > 357:
			angle = value - 360
			return
		if value < 0:
			angle = 360 + value
			return
		angle = value
var win_count:= 0
var loss_count:= 0
var id: int

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var mass

func _ready():
	trajectory.player = self
	trajectory.position = player.hud.position
	trajectory.default_color = Globals.colors_by_player[player.resource_sprite_frame]
	trajectory.update_trajectory(angle, missile_power)
	
	user_input_component.player = self
	if human:
		keyboard_profile = "player_" + str(id + 1) + "_"
	else:
		keyboard_profile = "ai_"
	name = keyboard_profile
	tap_sfx.pitch_scale += id/10.0
	
	inventory = [INF, 10, 0, 5, 10]
	animated_sprite.sprite_frames = Globals.sprites_for_players[resource_sprite_frame]
	
	for collision_side in monitors.get_children():
		collision_side.connect("body_entered", _on_area_2d_body_entered)
		collision_side.collision_mask = 6
	mass = (collision_shape.shape.radius * 2) * collision_shape.shape.height
	
	for i in range(hud.get_child_count()):
		if hud.get_child(i) is Sprite2D:
			amount_power_sprites += 1
	
	for i in range(amount_power_sprites):
		var child = hud.get_child(i)
		var scale_factor = (i + 1) / float(amount_power_sprites)
		child.scale = Vector2(0.4, 0.4)
		child.scale *= scale_factor
		child.position.x = 64
		child.position.x *= scale_factor*scale_factor
		child.modulate = Globals.colors_by_player[resource_sprite_frame]
	if human:
		state_machine.current_state.transition.emit(state_machine.current_state, "attacking")
		
func _process(delta):
	label.text = "$: " + str(money) + "\nHp: " + str(HP) + "\n" + str(inventory) + text_temp + "\n" + str(stamina) + "\n" + str(Globals.playable_missiles_nodes[current_missile].name)
	angle_number.text = str(angle)
	power_label.text = str(missile_power)
	text_temp = ""
	if human:# change something like state machine when IA is fully implemented
		user_input_component.update_user_input(delta)
	
	set_percentage_visible_power(missile_power)
		
	hud.rotation = deg_to_rad(angle + 180)

func change_color_to_power(color: Color):
	for child in hud.get_children():
		child.modulate = color

func set_percentage_visible_power(power: int):
	var percentage = clamp(power, 0, 100)
	var num_true_items_visible = int(amount_power_sprites * percentage / 100.0)
	
	for i in range(num_true_items_visible):
		$HUD.get_children()[i].visible = true
	for i in range(num_true_items_visible, amount_power_sprites):
		$HUD.get_children()[i].visible = false
	
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
		exploded_missile.who_shoot.damage_done += damage * sign
		
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

func spend_current_missile_in_inventory(forced := false) -> void:
	if Globals.playable_missiles_nodes[current_missile].name == "Regenerate" and forced==false:
		return
	
	inventory[current_missile] -= 1
	if inventory[current_missile] < 1:
		change_current_missile_to_next_missile_in_inventory()
		
func change_current_missile_to_next_missile_in_inventory() -> void:
	current_missile += 1
	woosh_sfx.play()
	if current_missile >= Globals.PLAYABLE_MISSILES.size():
		current_missile = 0
	if inventory[current_missile] < 1:
		change_current_missile_to_next_missile_in_inventory()# stack overflow xdxd


func change_current_missile_to_previous_missile_in_inventory() -> void:
	woosh_sfx.play()
	if current_missile>0:
		current_missile -= 1;
	else:
		current_missile = Globals.PLAYABLE_MISSILES.size()-1;
	if inventory[current_missile]<1:
		change_current_missile_to_previous_missile_in_inventory()#stack overflow xdxd

func apply_missile_shot(missile: Node2D) -> Vector2:
	missile.rotation = deg_to_rad(angle) + PI / 2
	missile.position = hud.global_position
	var direction = Vector2(cos(deg_to_rad(angle + 180)), sin(deg_to_rad(angle + 180)))
	missile.apply_impulse(direction * missile_power * POWER_MULTIPLIER, Vector2.ZERO)
	missile.who_shoot = player
	
	return direction
