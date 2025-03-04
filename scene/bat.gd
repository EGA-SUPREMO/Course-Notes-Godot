extends Consumable
class_name Bat

@onready var collision_shape_2d: CollisionPolygon2D = $Area2D/CollisionPolygon2D
var linear_velocity:= 0
func _ready() -> void:
	get_parent().remove_child(self)
	who_shoot.hud.add_child(self)
	position = Vector2.ZERO
	rotation = deg_to_rad(-90)
	


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		print(body.linear_velocity)
		print(body.angular_velocity)
		body.linear_velocity = -body.linear_velocity
		body.angular_velocity = -body.angular_velocity
