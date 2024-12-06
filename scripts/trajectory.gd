extends Line2D

var player: Player

func update_trajectory(angle: int, power: int, max_points = 4000, timestep = 0.02) -> void:
	if not visible:
		return
	#clear_points()
	
	points = calculate_trajectory(angle, power, max_points, timestep)

func calculate_trajectory(angle: int, power: int, max_points = 4000, timestep = 0.02) -> PackedVector2Array:
	var new_points:= []
	var pos = Vector2.ZERO
	var direction = Vector2(cos(deg_to_rad(angle + 180)), sin(deg_to_rad(angle + 180)))
	var speed: float = power * player.POWER_MULTIPLIER/32.34
	var velocity = direction * speed
	
	for i in max_points:
		new_points.append(pos)
		velocity.y += PhysicsServer2D.AREA_PARAM_GRAVITY * timestep
		pos += velocity * timestep
	return new_points
