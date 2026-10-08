extends WorldEnvironment


@onready var sky_mat: ShaderMaterial = environment.sky.sky_material
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sky_mat.set_shader_parameter("reveal_amount", 0.0)
