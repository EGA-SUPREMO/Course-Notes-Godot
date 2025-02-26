extends Missile

@export var damage_per_speed: Curve#change name? more linear velocity, more damage and bigger explocion

func _ready() -> void:
	pass # Replace with function body.

func explode() -> void:
	sfx_explotion.play()
	animated_sprite_2d.play("default")
	damage = damage_per_speed.sample(linear_velocity.abs().length()/500) * 100
	print(damage_per_speed.sample(linear_velocity.abs().length()/500))
	print()
	
	explotion.emit()
	get_tree().call_group("destructibles", "destroy", self)
