extends MeshInstance3D

@onready var player: Player = get_tree().get_first_node_in_group("player")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if player:
		if player.has_key:
			material_overlay.set_shader_parameter("highlight_strength", 1.0)
		else:
			material_overlay.set_shader_parameter("highlight_strength", 0.0)
