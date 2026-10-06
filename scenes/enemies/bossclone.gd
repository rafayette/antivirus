extends Enemy

func _process(delta: float) -> void:
	global_position.y = 1.2

func _ready() -> void:
	sprite = $AnimatedSprite3D
	health = 1
	temperature_per_tick = 0.7
