extends Node2D
class_name Consumable

const consumable := true
@export var price : int
var who_shoot: Player
var is_permanent := false

func apply_impulse(_ignore1, _ignore2) -> void:
	return
