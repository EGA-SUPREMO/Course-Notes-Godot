extends Missile

@export var damage_per_speed: Curve#change name? more linear velocity, more damage and bigger explocion

func _ready() -> void:
	animated_sprite_2d.speed_scale = 2

func _physics_process(_delta):
	pass

func explode() -> void:
	damage = damage_per_speed.sample(linear_velocity.abs().length()/1000) * 100 * 0.75
	if damage < 1:
		return
	sfx_explotion.play()
	animated_sprite_2d.visible = true
	animated_sprite_2d.scale.x = float(damage)/70 + 0.2
	animated_sprite_2d.scale.y = float(damage)/70 + 0.2
	animated_sprite_2d.play("default")
	
	explotion.emit()
	get_tree().call_group("destructibles", "destroy", self)
