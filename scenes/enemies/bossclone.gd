extends Enemy

func _process(_delta: float) -> void:
	global_position.y = 1.2

func _ready() -> void:
	add_to_group("entity")
	sprite = $AnimatedSprite3D
	health = 1
	temperature_per_tick = 0.7
