extends Consumable
class_name Bat

@onready var collision_shape: CollisionPolygon2D = $Area2D/CollisionPolygon2D
var linear_velocity:= 0
var last_position_collision: Vector2
@onready var polygon: Polygon2D = $Polygon

func _ready() -> void:
	animated_sprite_effect_node = preload("res://scene/animated_explotion.tscn").instantiate()
	animated_sprite_effect_node.scale /= 3
	get_parent().remove_child(self)
	who_shoot.hud.add_child(self)
	position = Vector2.ZERO
	rotation = deg_to_rad(-90)
	
	polygon.position = collision_shape.position
	polygon.polygon = collision_shape.polygon
	polygon.rotation = collision_shape.rotation
	polygon.scale = collision_shape.scale
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		body.linear_velocity = -body.linear_velocity*1.1
		body.angular_velocity = -body.angular_velocity*1.1
		last_position_collision = body.global_position
		print(body.global_position)
		print(global_position)
		print(body)
		effect.emit()

func _on_life_span_timeout() -> void:
	queue_free()
