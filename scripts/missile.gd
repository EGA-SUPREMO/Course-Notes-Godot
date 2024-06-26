extends RigidBody2D

@export var SPEED := 500
var new_rotation: float
@onready var timer = $Timer
var should_draw := false

func _ready():
	timer.start(0.05)

func _physics_process(delta):
	new_rotation = atan2(linear_velocity.y, linear_velocity.x)
	if should_draw:#there is a nasty bug, that upon instantiating the scene, velocity and susequentemente rotation is 0 and misile from 1 frame to another changes make a wide turn, donot remove
		rotation = new_rotation + PI / 2

func _on_timer_timeout():
	should_draw = true
