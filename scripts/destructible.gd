extends Node2D
@onready var shape_sprite = $ShapeSprite
@onready var collision_holder = $CollisionHolder

func _ready():
	build_collision_from_image()

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
		
		
		
