extends Missile
class_name Hotshower


var number_missiles := 7
var has_fallen:= false
const MISSILE = preload("res://scene/missile.tscn")

func _ready() -> void:
	super._ready()
	
func _process(delta: float) -> void:
	if linear_velocity.y > 0 and not has_fallen:
		drop_bomb()
		#explode()
		collision_shape_2d.set_deferred("disabled", true)
		has_fallen = true

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func _on_body_entered(_body: Node) -> void:
	super._on_body_entered(_body)

func drop_bomb():
	for i in range(1, number_missiles+1):
		var child_missile = MISSILE.instantiate()
		child_missile.collision_height = 2
		
		child_missile.rotation = rotation
		child_missile.position.y = position.y
		child_missile.position.x = position.x + ((i-number_missiles/2) * 10)
		
		var step = number_missiles / float(number_missiles - 1) if number_missiles > 1 else 0
		var step_multiplier = linear_velocity * 0.95
		
		child_missile.linear_velocity = linear_velocity + (step * Vector2(i,i) * step_multiplier)
		child_missile.who_shoot = who_shoot
		
		child_missile.collision_layer = 4  # Layer 4 (Mini child_missiles)
		child_missile.collision_mask = 1 | 2  # Collides with players/enemies (Layer 1) and terrain (Layer 2)
		
		get_tree().get_current_scene().add_child(child_missile)
	
