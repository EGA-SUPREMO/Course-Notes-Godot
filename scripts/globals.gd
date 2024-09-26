extends Node
class_name Global

static func calculate_strength_knockback(target_position: Vector2, source_position: Vector2, force: float, mass: float) -> Vector2:
	var direction: Vector2 = target_position - source_position
	var distance: float = direction.length()

	if distance > 0:
		direction = direction.normalized()
		var impulse_strength: float = force / distance
		impulse_strength *= mass * 0.75
		
		return direction * impulse_strength
	
	return Vector2.ZERO
