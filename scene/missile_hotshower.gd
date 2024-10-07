extends Missile
class_name Hotshower


var number_missiles := 7
var has_fallen:= false
const MISSILE = preload("res://scene/missile.tscn")

func _ready() -> void:
	damage = 30
	missile.mass = collision_shape_2d.shape.size.x * collision_shape_2d.shape.size.y
	timer.start(0.015)
	sfx_explotion.pitch_scale = randf() + 0.75
	
func _process(delta: float) -> void:
	if linear_velocity.y > 0 and not has_fallen:
		explode()
		collision_shape_2d.set_deferred("disabled", true)
		set_deferred("has_fallen", true)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func explode() -> void:
	call_deferred("drop_bomb")
	super.explode()
	
func _on_body_entered(_body: Node) -> void:
	super._on_body_entered(_body)

func drop_bomb():
	if has_fallen:
		return
	has_fallen = true
	
	for i in range(-number_missiles/2, number_missiles/2 + 1):
		var child_missile = MISSILE.instantiate()
		child_missile.collision_height = 2
		
		child_missile.rotation = rotation
		child_missile.position.y = position.y# - collision_shape_2d.shape.size.y/2 
		child_missile.position.x = position.x + number_missiles * 1
		
		var step_multiplier = linear_velocity * 0.05
		
		child_missile.linear_velocity = linear_velocity + (Vector2(i,i) * step_multiplier)
		child_missile.who_shoot = who_shoot
		
		child_missile.collision_layer = 4  # Layer 4 (Mini child_missiles)
		child_missile.collision_mask = 1 | 2  # Collides with players/enemies (Layer 1) and terrain (Layer 2)
		
		get_tree().get_current_scene().missiles.add_child(child_missile)
	
