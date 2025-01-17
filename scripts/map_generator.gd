extends Node
@onready var terrain: Node2D = $".."

var frequencies_amplitudes_plains := [
	[Vector2(1, 1.0), Vector2(2, 0.6), Vector2(4, 0.4)],
	[Vector2(1, 1.0), Vector2(2, 0.1), Vector2(4, 0.1), Vector2(8, 0.1)]
	]
var amplitude_size_plains := 50

var frequencies_amplitudes_desert := [
	[Vector2(1, 1.0), Vector2(4, 0.2), Vector2(8, 0.1), Vector2(16, 0.05)],
	[Vector2(1, 1.0), Vector2(2, 0.1), Vector2(4, 0.3), Vector2(8, 0.15), Vector2(16, 0.10)]
	]
var amplitude_size_desert := 25

var frequencies_amplitudes_snow := [
	[Vector2(1, 1.0), Vector2(2, 0.75), Vector2(4, 0.5), Vector2(8, 0.25), Vector2(16, 0.125)],
	[Vector2(1, 1.0), Vector2(2, 0.75), Vector2(4, 0.5), Vector2(8, 0.25), Vector2(16, 0.125), Vector2(32, 0.063)],
	[Vector2(2, 1.0), Vector2(5, 0.5), Vector2(10, 0.167), Vector2(12, 0.066)]
	]
var amplitude_size_snow := 75
var frequencies_amplitudes_mesa := frequencies_amplitudes_desert
var amplitude_size_mesa := 25

var frequencies_amplitudes := [frequencies_amplitudes_desert, frequencies_amplitudes_mesa,
	frequencies_amplitudes_snow, frequencies_amplitudes_plains]
var general_amplitudes := [amplitude_size_desert, amplitude_size_mesa, amplitude_size_snow,
	amplitude_size_plains]

var y_height_offset = [0.30, 0.30, 0.5, 0.5]
var amplitude = 50
var random = RandomNumberGenerator.new()



func create_bitmap(noise_map):
	var terrain_heights = Array()
	terrain_heights.resize(1280)
	terrain_heights.fill(0)
	if terrain.biome_id == 1:
		noise_map = add_additional_mountains(noise_map, 40 + randi_range(-10, 10))
	var min_value = noise_map.min()
	var max_value = noise_map.max()
	var range = max_value - min_value
	
	# Normalize the noise map to fit within the BitMap height
	var bitmap_height = int(range)
	var normalized_map = []
	for value in noise_map:
		normalized_map.append((value - min_value) / range * (bitmap_height - 1))
	var biome_offset_height = Globals.MAP_SIZE.y/2*y_height_offset[terrain.biome_id]
	
	var map_height = range + biome_offset_height
	var bitmap = BitMap.new()
	bitmap.create(Vector2i(Globals.MAP_SIZE.x, map_height))  # Create the BitMap
	
	for x in range(Globals.MAP_SIZE.x):
		for y in range(map_height):
			# Mark everything below the noise value as "true" (1)
			if y < normalized_map[x]:
				bitmap.set_bit(x, y, false)
			else:
				bitmap.set_bit(x, y, true)
	return bitmap


## UTILs

func generate_map(frequencies_amplitudes: Array, amplitude_size: int) -> Array:
	amplitude = amplitude_size
	var noises = []
	var amplitudes:= []
	for frequency_amplitude in frequencies_amplitudes:
		amplitudes.append(frequency_amplitude.y)
	
	# Generate noise for each frequency
	for freq in frequencies_amplitudes:
		noises.append(generate_noise(freq.x))
		
	return combine_with_weights(amplitudes, noises)

func combine_with_weights(amplitudes: Array, noises: Array) -> Array:
	var final_noise = []
	
	for x in range(Globals.MAP_SIZE.x):
		final_noise.append(0.0)
	
	for k in range(noises.size()):
		for x in range(Globals.MAP_SIZE.x):
			final_noise[x] += amplitudes[k] * noises[k][x]
	
	return final_noise

func generate_noise(frequency: int) -> Array:
	var output = []
	var phase = random.randf() * 2.0 * PI
	
	for x in range(Globals.MAP_SIZE.x):
		var value = amplitude * sin(2.0 * PI * frequency * x / Globals.MAP_SIZE.x + phase)
		output.append(value)
	
	return output



# Properties for the terrain generation
var heights : Array = []
var edge_width : float
var transition_width : float
var max_edge_height : float
var top_height : float
var transition_slope : float

func add_additional_mountains(heights: Array, max_height: int) -> Array:
	# Randomly determine the number of additional mountains to generate
	var random_chance = randi_range(1, 100)
	var number_of_mountains
	if random_chance < 53:
		number_of_mountains = 2
	elif random_chance < 81:
		number_of_mountains = 3 
	elif random_chance < 93:
		number_of_mountains = 1 
	else:
		number_of_mountains = 0
	
	var is_valley
	if randi_range(0, 1) == 0:
		is_valley = -1
	else:
		is_valley = 1
	# Loop through to generate the specified number of additional mountains
	for i in range(number_of_mountains):
		# Generate a new mountain section with random width and height
		var minimum_width := Globals.MAP_SIZE.x / 20
		var mountain_width := int(heights.size() / 8 + randf() * (Globals.MAP_SIZE.x / number_of_mountains - heights.size() / 8) + minimum_width)
		var mountain = generate_mountains(mountain_width, max_height)
		
		#if randi_range(0, 1) == 0:
			#is_valley = -1
		#else:
			#is_valley = 1
		for j in range(mountain.size()):
			var index = j + i * mountain.size()
			if index < heights.size():
				heights[index] += mountain[j] * is_valley
	return heights
# Constructor equivalent in Godot
func generate_part_mount_mesa(width: int, max_height: int) -> Array:
	heights.resize(width)
	
	# Calculate edge width and transition width
	edge_width = width / 3.0
	transition_width = edge_width / 12.0
	edge_width -= transition_width

	# Calculate maximum edge height and top height
	max_edge_height = width * width # Used to normalize the quadratic curve
	top_height = max_height * 4.0 # Maximum height scaling factor
	transition_slope = (max_height - ((edge_width * edge_width / max_edge_height) * top_height)) / transition_width

	# Round edge width and transition width for consistent indexing
	edge_width = round(edge_width)
	transition_width = round(transition_width)

	# Generate heights for the left edge (quadratic curve)
	for i in range(int(edge_width) + 1):
		heights[i] = (i * i / max_edge_height) * top_height

	# Generate heights for the left transition region (linear increase)
	for i in range(int(transition_width)):
		heights[int(edge_width) + i] = heights[int(edge_width)] + transition_slope * i

	# Generate heights for the middle flat region
	for i in range(int(edge_width + transition_width), width - int(edge_width) - int(transition_width)):
		heights[i] = max_height * 2.0

	# Generate heights for the right edge (quadratic curve)
	for i in range(int(edge_width)):
		heights[width - i - 1] = (i * i / max_edge_height) * top_height

	# Generate heights for the right transition region (linear increase)
	for i in range(int(transition_width)):
		heights[width - int(edge_width) - i - 1] = heights[width - int(edge_width)] + transition_slope * i
	
	return heights

func generate_mountains(width: int, height: int) -> Array:
	var terrain_heights = Array()
	terrain_heights.resize(width)
	terrain_heights.fill(0)
	var max_height = height # The maximum height of the mountains

	# Determine the number of main mountain sections based on random chance
	var random_chance = randi() % 100
	var main_mountain_count
	if random_chance < 53:
		main_mountain_count = 2
	else:# random_chance < 81:
		main_mountain_count = 3
	#else:
	#	main_mountain_count = 4

	var remaining_width = width # Track the remaining width for placing mountains

	# Generate the main mountain sections
	for i in range(main_mountain_count):
		# Generate a new mountain section with a random width and height
		var mountain_width = int(width / 4 + randf() * (remaining_width - width / 4))
		var mountain_height = max_height * 2
		var mountain_section = generate_part_mount_mesa(mountain_width, mountain_height)

		# Update the remaining width after the first mountain section
		if i != 0:
			remaining_width = mountain_section.size()

		# Add the current mountain section's heights to the overall terrain
		for j in range(mountain_section.size()):
			terrain_heights[j] += mountain_section[j]

	return terrain_heights
