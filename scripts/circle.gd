extends Node2D

var _radius := 40

func reposition(positio: Vector2, radius: int) -> void:
	visible = true
	
	global_position = positio
	_radius = radius
	
	# to force a redraw
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, _radius, Color.BLACK)
