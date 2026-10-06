extends Enemy
class_name Item

enum ItemTypes {Bomb, Ram, Cooling}
@export var item_type : ItemTypes

func _ready() -> void:
	sprite = $AnimatedSprite3D
	temperature_per_tick = 0.0
	item_type = ItemTypes.values().pick_random()
	#speed = 0.0
	chases_player = false
	add_to_group("item")
	if item_type == ItemTypes.Bomb:
		sprite.material_overlay.set_shader_parameter("highlight_color", Color.html("#ff0000"))

func pick_up(player: Player) -> void:
	match item_type:
		ItemTypes.Cooling:
			player.temperature -= 40
			player.item_picked_up("+COOLING", false)
		ItemTypes.Ram:
			player.ram = min(player.ram + 30, 100)
			player.item_picked_up("+RAM", false)
		ItemTypes.Bomb:
			player.temperature += 40
			player.item_picked_up("-ZIP_BOMB", true)
	queue_free()
