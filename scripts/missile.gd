extends RigidBody2D
class_name Missile

var new_rotation: float
@onready var timer = $Timer
@export var damage: int
var should_draw := false
var who_shoot: CharacterBody2D

signal explotion
@onready var missile = $"."
@onready var collision_shape_2d = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sfx_explotion: AudioStreamPlayer2D = $SFX_Explotion


func _ready():
	damage = 30
	missile.mass = (collision_shape_2d.shape.radius * 2) * collision_shape_2d.shape.height
	timer.start(0.015)
	sfx_explotion.pitch_scale = randf() + 0.75

func _physics_process(_delta):
	new_rotation = atan2(linear_velocity.y, linear_velocity.x)
	if should_draw:#there used to be a nasty bug, that upon instantiating the scene, velocity and susequentemente rotation is 0 and misile from 1 frame to another changes make a wide turn, donot remove
	#but seems like it disappeared :v
		rotation = new_rotation + PI / 2
	
func _on_timer_timeout():
	should_draw = true

func _on_body_entered(_body: Node) -> void:
	if collision_shape_2d.disabled:#WTF GODOT!
		return
	get_tree().call_group("destructibles", "destroy", self)
	animation_player.play("explotion")
	collision_shape_2d.set_deferred("disabled", true)
	explotion.emit()
	
