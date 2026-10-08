extends Enemy

func _process(_delta: float) -> void:
	global_position.y = 1.2

func _ready() -> void:
	sprite = $AnimatedSprite3D
	health = 1
	add_to_group("entity")
