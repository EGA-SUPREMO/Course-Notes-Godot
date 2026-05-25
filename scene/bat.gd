extends Consumable
class_name Bat

@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
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
	
func _draw():
	# Draws a circle (position, Radius, Thickness)
	draw_circle(Vector2.ZERO, 60.0, Color.DEEP_SKY_BLUE)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is not RigidBody2D:
		return
	if body is Missile and body.who_shoot == who_shoot and body.age <= 0.16:
		return

	body.linear_velocity = -body.linear_velocity*1.1
	body.angular_velocity = -body.angular_velocity*1.1
	last_position_collision = body.global_position
	effect.emit()

func _on_life_span_timeout() -> void:
	queue_free()
