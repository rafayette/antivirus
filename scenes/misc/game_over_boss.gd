extends CanvasLayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible:
		$SFX.autoplay = true

func play_boss_noise() -> void:
	$SFX.play()
