extends Consumable


func _ready() -> void:
	queue_free()
	if who_shoot.HP == who_shoot.max_hp:
		get_parent().get_parent().fail_to_regenarate_sfx.play()
		return
	get_parent().get_parent().successful_regenaratation_sfx.play()
	who_shoot.spend_current_missile_in_inventory(true)
	who_shoot.HP = clampi(who_shoot.HP + 10, 0, who_shoot.max_hp)

func apply_impulse(_ignore1, _ignore2) -> void:
	return
