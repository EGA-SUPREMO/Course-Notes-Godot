extends CharacterBody2D
class_name Player

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite = $AnimatedSprite2D
@onready var state_machine: Node = $StateMachine
@onready var hurt_sfx: AudioStreamPlayer2D = $HurtSFX
@onready var label: Label = $Label
@onready var woosh_sfx: AudioStreamPlayer2D = $WooshSFX
@onready var run_sfx: AudioStreamPlayer2D = $RunSFX
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var missile_power := 50:
	set(value):
		missile_power = value
		if missile_power > 100:
			missile_power -= 110
		elif missile_power < 0:
			missile_power += 110
		if tap_sfx and trajectory:
			tap_sfx.pitch_scale = 0.5 + missile_power/100.0
			tap_sfx.play()
			trajectory.update_trajectory(angle, missile_power)
@export var keyboard_profile: String
@warning_ignore("unused_signal")
signal shoot
signal death


var active_item_type := 0
var current_missile:= 0
var current_consumable:= 0
var selectedItem := 0:
	get():
		if active_item_type:
			return current_consumable
		return current_missile
var inventory : Array
var stamina:= 500
var damage_done: int
var text_temp : String
@onready var player = $"."
@onready var hud = $HUD
@onready var monitors: Node2D = $Monitors
@onready var trajectory: Line2D = $Trajectory
#var too_early_shoot_timer := Timer.new()
@onready var death_sfx: AudioStreamPlayer2D = $DeathSFX
@onready var switch_type_item_sfx: AudioStreamPlayer2D = $SwitchTypeItemSFX

var max_hp := 100.0
var max_stamina := 300
var HP:= max_hp:
	set(value):
		if HP <= 0 and value <= HP:
			return
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
const POWER_MULTIPLIER = 15

@export var resource_sprite_frame: int
@export var human: bool
@onready var user_input_component: UserInputComponent = $UserInputComponent
@onready var angle_number: Label = $HUD/AngleNumberLabel
var amount_power_sprites: int
@onready var power_label: Label = $HUD/PowerLabel
@onready var tap_sfx: AudioStreamPlayer2D = $TapSFX
@onready var throw_sfx: AudioStreamPlayer2D = $ThrowSFX
@onready var second_shot_sfx: AudioStreamPlayer2D = $SecondShotSFX
@onready var missile_sprite: Sprite2D = $MissileSprite

@export var angle := 0.0:
	set(value):
		#if animated_sprite:
			#var max_angle = 270 if !animated_sprite.flip_h else 90
			#var min_angle = 90 if !animated_sprite.flip_h else 270
			#print(min_angle)
			#if value < min_angle:
				#angle = min_angle
				#return
			#elif value > max_angle:
				#angle = max_angle
				#return
		if value == angle:
			return
		if tap_sfx and trajectory:
			trajectory.update_trajectory(value, missile_power)
			#tap_sfx.pitch_scale = 1
			tap_sfx.play()
			
		angle = fposmod(value, 360)
var win_count:= 0
var loss_count:= 0
var id: int
var wants_shoot:= false:
	set(value):
		if value:
			hud.material.set_shader_parameter("player_color", Color.GRAY)
			player.change_color_to_power(Color.GRAY)
		else:
			hud.material.set_shader_parameter("player_color", Globals.colors_by_player[player.resource_sprite_frame])
		wants_shoot = value

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var mass
#var can_shoot = false

func _ready():
	hurt_sfx.pitch_scale = randf() + 0.75
	trajectory.player = self
	trajectory.position = player.hud.position
	trajectory.default_color = Globals.colors_by_player[player.resource_sprite_frame]
	hud.material = hud.material.duplicate()
	hud.material.set_shader_parameter("player_color", trajectory.default_color)
	trajectory.update_trajectory(angle, missile_power)
	
	user_input_component.player = self
	if human:
		keyboard_profile = "player_" + str(id + 1) + "_"
		#too_early_shoot_timer.wait_time = 0.5
		#get_tree().create_timer(0.5)
	else:
		keyboard_profile = "ai_"
		#too_early_shoot_timer.wait_time = 1
		#get_tree().create_timer(1)
	name = keyboard_profile
	
	#can_shoot = false
	#can_shoot = true
	#too_early_shoot_timer.autostart = true
	#too_early_shoot_timer.one_shot = true
	#too_early_shoot_timer.timeout.connect(on_early_shoot_timeout)
	#player.add_child(too_early_shoot_timer)
	
	tap_sfx.pitch_scale += id/10.0
	
	inventory = [[INF, 5, 0, 10], [5, 10, 30]]
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
	
	missile_sprite.position = hud.position
	missile_sprite.texture = Globals.PLAYABLE_MISSILE_ICONS[active_item_type][selectedItem]
	
func _process(delta):
	label.text = "\nHp: " + str(HP) + text_temp + "\n" + str(stamina)
	angle_number.text = str(map_angle(angle + 90))
	power_label.text = str(missile_power)
	text_temp = ""
	if human:# change something like state machine when IA is fully implemented
		user_input_component.update_user_input(delta)
	
	set_percentage_visible_power(missile_power)
		
	hud.rotation = deg_to_rad(angle)

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
		var sign_damage = ( -1 if exploded_missile.who_shoot == self else 1 )
		exploded_missile.who_shoot.money += damage * sign_damage * MONEY_MULTIPLIER
		exploded_missile.who_shoot.damage_done += damage * sign_damage
		
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
	$BonkSFX.pitch_scale = randf() + 0.75
	$BonkSFX.play()
	var angular_force = _body.angular_velocity * _body.mass
	var linear_force = _body.linear_velocity.length() * _body.mass
	var total_force = angular_force + linear_force# TODO este metodo le falta chicha
	
	HP -= total_force/20000

func switch_item_type():
	if active_item_type == 1:
		active_item_type = 0
	else:
		active_item_type = 1
	switch_type_item_sfx.play()
	missile_sprite.texture = Globals.PLAYABLE_MISSILE_ICONS[active_item_type][selectedItem]

func spend_current_missile_in_inventory(forced := false) -> void:
	if Globals.playable_missiles_nodes[active_item_type][selectedItem].name == "Regenerate" and forced==false:
		return
	
	inventory[active_item_type][selectedItem] -= 1
	if inventory[active_item_type][selectedItem] < 1:
		change_current_missile_to_next_missile_in_inventory()
		
func change_current_missile_to_next_missile_in_inventory() -> void:
	if active_item_type:
		current_consumable += 1
	else:
		current_missile += 1
	woosh_sfx.play()
	if selectedItem >= Globals.PLAYABLE_MISSILES[active_item_type].size():
		if active_item_type:
			current_consumable = 0
		else:
			current_missile = 0
	if inventory[active_item_type][selectedItem] < 1:
		change_current_missile_to_next_missile_in_inventory()# stack overflow xdxd

	missile_sprite.texture = Globals.PLAYABLE_MISSILE_ICONS[active_item_type][selectedItem]

func change_current_missile_to_previous_missile_in_inventory() -> void:
	woosh_sfx.play()
	if active_item_type:
		if current_consumable>0:
			current_consumable -= 1;
		else:
			current_consumable = Globals.PLAYABLE_MISSILES[active_item_type].size()-1;
	else:
		if current_missile>0:
			current_missile -= 1;
		else:
			current_missile = Globals.PLAYABLE_MISSILES[active_item_type].size()-1;
	
	
	if inventory[active_item_type][selectedItem]<1:
		change_current_missile_to_previous_missile_in_inventory()#stack overflow xdxd

	missile_sprite.texture = Globals.PLAYABLE_MISSILE_ICONS[active_item_type][selectedItem]

func apply_missile_shot(missile: Node2D) -> Vector2:
	missile.rotation = deg_to_rad(angle)
	missile.position = hud.global_position
	var direction = Vector2(cos(deg_to_rad(angle)), sin(deg_to_rad(angle)))
	missile.apply_impulse(direction * missile_power * POWER_MULTIPLIER, Vector2.ZERO)
	missile.who_shoot = player
	
	return direction

func die() -> void:
	get_parent().remove_child(player)
	MatchManager.players.call_deferred("add_child", player)
	player.animation_player.play("RESET")

#func on_early_shoot_timeout():
	#can_shoot = true
	#too_early_shoot_timer.stop()
	#print(can_shoot)
	
func map_angle(angle: float) -> float:
	angle = fposmod(angle, 360)  # Normalize to [0, 360)
	var mapped_angle = 90 - fposmod(angle, 180)  # Map to 90 → 0 → -90 cycle
	
	if angle >= 180:
		mapped_angle *= -1  # Flip sign in the second half of the cycle
	
	return mapped_angle

func flip_angle_horizontally() -> void:
	angle = fposmod(180 - angle, 360)

func change_angle(delta_angle: int) -> void:
	if animated_sprite:
		if not animated_sprite.flip_h:
			delta_angle *= -1
		var new_value = angle + delta_angle
		if animated_sprite.flip_h:
			var max_angle = 270
			var min_angle = 90
			if new_value < min_angle:
				angle = min_angle
				return
			elif new_value > max_angle:
				angle = max_angle
				return
			angle = new_value
			return
		var in_upper_left_arc = new_value < 270 && new_value > 180
		var in_lower_left_arc = new_value > 90 && new_value < 180
		if in_upper_left_arc:
			angle = 270
			return
		elif in_lower_left_arc:
			angle = 90
			return
		angle = new_value
