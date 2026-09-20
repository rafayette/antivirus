extends WorldEnvironment
func _process(delta: float) -> void:
	environment.sky_rotation.y += delta * 0.05
