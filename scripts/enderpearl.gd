extends Missile
class_name Enderpearl

func explode() -> void:
	get_tree().call_group("destructibles", "destroy", self)
	animation_player.play("explotion")
	who_shoot.position.x = position.x
	who_shoot.position.y = position.y - 5
	collision_shape_2d.set_deferred("disabled", true)
	explotion.emit()
