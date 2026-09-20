extends AnimatedSprite2D

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")
@export var bob_speed_x = 1.0
@export var bob_size_x = 30.0
@export var bob_size_y = 10.0
var base_position: Vector2
var bob_time := 0.0
var tween: Tween

func _process(delta: float) -> void:
	var horizontal_speed: float = Vector2(player.velocity.x, player.velocity.z).length()
	var is_moving: bool = horizontal_speed > 0.1
	
	if is_moving:
		bob_time += horizontal_speed * delta * bob_speed_x
		var wave = sin(bob_time)
		position.x = base_position.x + (wave * bob_size_x)
		position.y = base_position.y + abs((wave * bob_size_y))
	else:
		if position != base_position:
			bob_time = 0.0
			tween = create_tween()
			tween.tween_property(self, "position", base_position, 0.1)

func _ready() -> void:
	base_position = position
