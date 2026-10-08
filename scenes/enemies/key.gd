extends Item

func _ready() -> void:
	add_to_group("item")
	add_to_group("entity")
	sprite = $AnimatedSprite3D
	temperature_per_tick = 0.0
	item_type = ItemTypes.values().pick_random()
	#speed = 0.0
	chases_player = false

func pick_up(_player: Player) -> void:
	player.has_key = true
	player.item_picked_up("+OBTAINED KEY", false)
	var keyhole = get_tree().get_first_node_in_group("keyhole")
	if keyhole:
		var keyhole_shader: ShaderMaterial = keyhole.material_overlay
		if keyhole_shader:
			keyhole_shader.set_shader_parameter("highlight_strength", 1.0)
	queue_free()
