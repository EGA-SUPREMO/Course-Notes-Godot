extends Node2D
@onready var shape_sprite = $ShapeSprite
@onready var collision_holder = $CollisionHolder
var world_size
var _destrotion_threads := Array()
@onready var sub_viewport = $SubViewport
@onready var cull_timer = $CullTimer

var _to_cull = Array()

func _ready():
	add_to_group("destructibles")
	
	world_size = shape_sprite.get_rect().size
	
	sub_viewport.size = world_size
	var dup = get_parent().duplicate(0) as Node2D
	_to_cull.append(dup)
	
	#dup.position = 
	sub_viewport.add_child(dup)
	
	await RenderingServer.frame_post_draw#(VisualServer#, "frame_post_draw")
	build_collision_from_image()

func rebuild_collision_from_geometry(arguments: Array):
	var position = arguments[0]
	var radius = arguments[1]
	
	position = position - global_position

	var nb_points = 8
	var points_arc = PackedVector2Array()
	points_arc.push_back(position)

	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(i * 360 / nb_points)
		points_arc.push_back(position + Vector2(cos(angle_point), sin(angle_point)) * radius)
	
	for collision_polygon in collision_holder.get_children():
		var clipped_polygons = Geometry2D.clip_polygons(collision_polygon.polygon, points_arc)

		# the whole polygon was destroyed
		if clipped_polygons == 0:
			clipped_polygons.queue_free()
			
		for i in range(clipped_polygons.size()):
			var clipped_collision = clipped_polygons[i]
			# These are awkward single or two-point floaters.
			if clipped_collision.size() < 3:
				continue
			#var points = PoolVector2Array
			if i == 0:
				#collision_polygon.call_deferred("set", "polygon", points)
				collision_polygon.call_deferred("set", "polygon", clipped_polygons)
			else:
				var collider := CollisionPolygon2D.new()
				collider.polygon = clipped_collision
				collision_holder.call_deferred("add_child", collider)

func build_collision_from_image():
	var bitMap = BitMap.new()
	bitMap.create_from_image_alpha(shape_sprite.texture.get_image())
	
	# debugging
	#shape_sprite.get_texture().get_image().save_png("res://screenshot.png")
	#bitMap.convert_to_image().save_png("res://screenshot.png")
	
	var polygons = bitMap.opaque_to_polygons(Rect2(Vector2(0, 0), bitMap.get_size()))

	for polygon in polygons:
		var collider = CollisionPolygon2D.new()
		
		var newpoints := Array()
		for point in polygon:
			newpoints.push_back(point)
		collider.polygon = newpoints
		collider.position.x -= bitMap.get_size().x/2
		collider.position.y -= bitMap.get_size().y/2
		collision_holder.add_child(collider)
		
		
func destroy(position: Vector2, radius: int):
	var thread := Thread.new()
	var callable = Callable(self, "rebuild_collision_from_geometry").bind(position, radius)
	var error = thread.start(callable)
	if error != OK:
		print("error creating thread for destroying map")
	_destrotion_threads.push_back(thread)
	
func _exit_tree():
	for thread in _destrotion_threads:
		thread.wait_to_finish()

func _on_cull_timer_timeout():
	for dup in _to_cull:
		dup.to_queue_free()
	_to_cull = Array()
