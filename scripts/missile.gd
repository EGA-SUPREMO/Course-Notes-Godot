extends RigidBody2D

var new_rotation: float
@onready var timer = $Timer
var damage: int
var should_draw := false
signal explosion
@onready var missile = $"."
@onready var collision_shape_2d = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready():
	missile.contact_monitor = true
	missile.mass = (collision_shape_2d.shape.radius * 2) * collision_shape_2d.shape.height
	timer.start(0.015)

func _physics_process(delta):
	new_rotation = atan2(linear_velocity.y, linear_velocity.x)
	if should_draw:#there used to be a nasty bug, that upon instantiating the scene, velocity and susequentemente rotation is 0 and misile from 1 frame to another changes make a wide turn, donot remove
	#but seems like it disappeared :v
		rotation = new_rotation + PI / 2
	
func _on_timer_timeout():
	should_draw = true

func _on_timer_2_timeout():
	#explosion.emit(position, 30)
	
	queue_free()


func _on_body_entered(body: Node) -> void:
	print("oex")
	animation_player.play("explotion")
