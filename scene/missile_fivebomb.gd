extends Missile
class_name Fivebomb

var number_missiles := 6
const MINI_MISSILE = preload("res://scene/mini_missile.tscn")

func _physics_process(_delta):
	pass

func explode():
	super.explode()
	
	for i in range(-number_missiles/2, number_missiles/2 + 1):
		var child_missile = MINI_MISSILE.instantiate()
		var rand_vector_position = Vector2(randf_range(-10, 10), randf_range(-10, 10))
		
		child_missile.damage = 20
		child_missile.rotation = randf() * PI * 2
		child_missile.position = position + rand_vector_position
		
		var velocity_multiplier = Vector2(1, 1)
		
		child_missile.linear_velocity = Vector2(
			Globals.random_float_in_ranges(-250, -100, 100, 250),
			Globals.random_float_in_ranges(-400, -200, 100, 300)) * velocity_multiplier
		child_missile.who_shoot = who_shoot
		
		get_tree().get_current_scene().missiles.call_deferred("add_child", child_missile)
