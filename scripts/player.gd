extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

signal shoot

const SPEED = 100.0
const JUMP_VELOCITY = -400.0

@onready var hud_angle = $hud_angle

@export var angle := 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _process(delta):
	if Input.is_action_just_released("shot"):
		shoot.emit()
	if Input.is_action_pressed("increase_angle"):
		angle += 2 * delta
	if Input.is_action_pressed("lower_angle"):
		angle -= 2 * delta
		
	#var new_x = Vector2(0, hud_angle.global_position.x).rotated(dir).x
	#hud_angle.global_position.x = new_x
	
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left_move", "right_move")


	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
