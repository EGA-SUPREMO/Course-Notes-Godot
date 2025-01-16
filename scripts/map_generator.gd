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

func generate_part_mount_mesa():
	pass
