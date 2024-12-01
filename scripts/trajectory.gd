extends Line2D


func update_trajectory(direction: Vector2, speed: float, delta: float) -> void:
	var max_points := 500
	clear_points()
	var pos = Vector2.ZERO
	var velocity = direction * speed
	
	for i in max_points:
		add_point(pos)
		velocity.y += PhysicsServer2D.AREA_PARAM_GRAVITY * delta
		pos += velocity * delta

func _process(delta: float) -> void:
	print("a")
	update_trajectory(Vector2(1, -1), 14, delta)
	
