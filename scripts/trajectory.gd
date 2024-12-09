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
	var terrain = get_tree().get_current_scene().get_node("/root/Main/Terrain").island_holder.get_children()
	
	for i in max_points:
		new_points.append(pos)
		velocity.y += PhysicsServer2D.AREA_PARAM_GRAVITY * timestep
		for polygon_body in terrain:
			#print(pos)
			#print(polygon_body.get_child(0).polygon)
			
			if Geometry2D.is_point_in_polygon(pos + player.hud.global_position, polygon_body.get_child(0).polygon):
				#print(polygon_body.get_child(0).polygon)
				#print(pos + player.hud.position)
				return new_points
		pos += velocity * timestep
		
		
	return new_points
