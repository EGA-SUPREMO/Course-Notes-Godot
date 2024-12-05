extends Line2D

var player: Player

func update_trajectory(angle: int, power: int) -> void:
	var timestep = 0.02
	var max_points := 1000
	clear_points()
	var pos = Vector2.ZERO
	var direction = Vector2(cos(deg_to_rad(angle + 180)), sin(deg_to_rad(angle + 180)))
	var speed: float = power * player.POWER_MULTIPLIER/32.35
	var velocity = direction * speed
	
	for i in max_points:
		add_point(pos)
		velocity.y += PhysicsServer2D.AREA_PARAM_GRAVITY * timestep
		pos += velocity * timestep
