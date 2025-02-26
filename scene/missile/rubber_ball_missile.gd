extends Missile

@export var damage_per_speed: Curve#change name? more linear velocity, more damage and bigger explocion


func _physics_process(_delta):
	pass

func explode() -> void:
	damage = damage_per_speed.sample(linear_velocity.abs().length()/500) * 100
	if damage < 1:
		return
	sfx_explotion.play()
	animated_sprite_2d.play("default")
	
	explotion.emit()
	get_tree().call_group("destructibles", "destroy", self)
