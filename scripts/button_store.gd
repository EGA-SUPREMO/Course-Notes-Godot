extends TextureButton

@onready var price_label: Label = $Price
@export var is_missile: bool

@export var price: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_missile:
		for j in range(Globals.playable_missiles_nodes.size()):
			if Globals.playable_missiles_nodes[j].name == name:
				price_label.text = str(Globals.playable_missiles_nodes[j].price)
				return
	price_label.text = str(price)
	
