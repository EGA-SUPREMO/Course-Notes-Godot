extends Missile
class_name Hotshower

var number_missiles := 7
var has_fallen:= false
const MINI_MISSILE = preload("res://scene/mini_missile.tscn")

func _ready() -> void:
	damage = 30
	missile.mass = collision_shape_2d.shape.size.x * collision_shape_2d.shape.size.y
	timer.start(0.015)
	sfx_explotion.stream = preload("res://assets/sounds/bolt sliding back from Pixabay.mp3")
	sfx_explotion.pitch_scale = randf() + 0.75
	
func _process(_delta: float) -> void:
	if linear_velocity.y > 0 and not has_fallen:
		disappear()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func disappear() -> void:
	animation_player.play("disappear")
	collision_shape_2d.set_deferred("disabled", true)
	call_deferred("drop_bomb")
	
func explode() -> void:
	call_deferred("drop_bomb")
	sfx_explotion.stream = preload("res://assets/sounds/explosion.wav")
	
	super.explode()
	
func _on_body_entered(_body: Node) -> void:
	super._on_body_entered(_body)

func drop_bomb():
	if has_fallen:
		return
	has_fallen = true
	
	spawn_mini_bombs()
	
func spawn_mini_bombs():
	for i in range(-number_missiles/2, number_missiles/2 + 1):
		var child_missile = MINI_MISSILE.instantiate()
		
		child_missile.rotation = rotation
		child_missile.position.y = position.y# - collision_shape_2d.shape.size.y/2 
		child_missile.position.x = position.x + number_missiles * 1
		
		var relative_step_multiplier = linear_velocity * 0.025
		var base_step_multiplier = Vector2(35, 0)
		var step_multiplier = base_step_multiplier + relative_step_multiplier
		
		child_missile.linear_velocity = linear_velocity + (Vector2(i,i) * step_multiplier)
		child_missile.who_shoot = who_shoot
		
		get_tree().get_current_scene().call_deferred("add_child", child_missile)
	
