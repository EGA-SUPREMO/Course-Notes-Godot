extends Consumable
class_name Bat

@onready var collision_shape: CollisionPolygon2D = $Area2D/CollisionPolygon2D
var linear_velocity:= 0

@onready var polygon: Polygon2D = $Polygon

func _ready() -> void:
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


func _on_life_span_timeout() -> void:
	queue_free()
