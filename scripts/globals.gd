extends Node
class_name Global

const SCENE_MISSILE = preload("res://scene/missile.tscn")
const SCENE_MISSILE_HOTSHOWER = preload("res://scene/missile_hotshower.tscn")
const SCENE_NUCLEAR_MISSILE = preload("res://scene/nuclear_missile.tscn")
const SCENE_MISSILE_FIVEBOMB = preload("res://scene/missile_fivebomb.tscn")
const ENDERPEARL = preload("res://scene/enderpearl.tscn")
const REGENERATE = preload("res://scene/regenerate.tscn")

const PLAYABLE_MISSILES = [SCENE_MISSILE_FIVEBOMB, SCENE_MISSILE_HOTSHOWER,
	SCENE_NUCLEAR_MISSILE, ENDERPEARL, REGENERATE]
var playable_missiles_nodes: Array

var sprites_for_players = [preload("res://scene/player_zeta.tres"),
	preload("res://scene/player_pemaloe.tres"),
	preload("res://scene/player_merakyat.tres"),
	preload("res://scene/player_risu.tres"),
	preload("res://scene/player_moonafic.tres")
	]

var colors_by_player = [Color.BLACK.clamp(0, Color(1, 1, 1, 0.75)),
	Color.RED.clamp(0, Color(1, 1, 1, 0.75)),
	Color.BLUE.clamp(0, Color(1, 1, 1, 0.75)),
	Color.PINK.clamp(0, Color(1, 1, 1, 0.75)),
	Color.PURPLE.clamp(0, Color(1, 1, 1, 0.75))]

var current_match_count = 0
var max_number_match = 3

func _ready() -> void:
	for missile in PLAYABLE_MISSILES:
		playable_missiles_nodes.append(missile.instantiate())
		

func counting():
	current_match_count += 1

static func calculate_strength_knockback(target_position: Vector2, source_position: Vector2, force: float, mass: float) -> Vector2:
	var direction: Vector2 = target_position - source_position
	var distance: float = direction.length()

	if distance > 0:
		direction = direction.normalized()
		var impulse_strength: float = force / distance
		impulse_strength *= mass * 0.75
		
		return direction * impulse_strength
	
	return Vector2.ZERO

func get_closest_distance_to_shape(collision_shape: CollisionShape2D, target_position: Vector2) -> float:
	var global_transform = collision_shape.global_transform
	var capsule_shape = collision_shape.shape as CapsuleShape2D

	var rect_width = capsule_shape.height
	var rect_height = capsule_shape.radius * 2
	var rect_extents = Vector2(rect_width / 2, rect_height / 2)
	
	var top_left = global_transform.origin - Vector2(rect_extents.x, rect_extents.y)
	var top_right = global_transform.origin + Vector2(rect_extents.x, -rect_extents.y)
	var bottom_left = global_transform.origin + Vector2(-rect_extents.x, rect_extents.y)
	var bottom_right = global_transform.origin + rect_extents
	
	var edges = [
		[top_left, top_right],
		[top_right, bottom_right],
		[bottom_right, bottom_left],
		[bottom_left, top_left]
	]
	var closest_point = global_transform.origin  # Initialize with the center of the shape
	var min_distance = INF

	for edge in edges:
		var p1 = edge[0]
		var p2 = edge[1]
		var closest_on_edge = Geometry2D.get_closest_point_to_segment(target_position, p1, p2)
		var distance = target_position.distance_to(closest_on_edge)

		if distance < min_distance:
			min_distance = distance
			closest_point = closest_on_edge

	return min_distance

func random_float_in_ranges(min_negative, max_negative, min_positive, max_positive) -> float:
	var range_choice = randi() % 2
	if range_choice:
		return randf_range(min_negative, max_negative)
	return randf_range(min_positive, max_positive)
