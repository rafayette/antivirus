extends Item

func _ready() -> void:
	add_to_group("item")
	sprite = $AnimatedSprite3D
	temperature_per_tick = 0.0
	item_type = ItemTypes.values().pick_random()
	#speed = 0.0
	chases_player = false

func pick_up(player: Player) -> void:
	print("SETTING HAS KEY TO TRUE")
	player.has_key = true
	player.item_picked_up("+OBTAINED KEY", false)
	queue_free()
