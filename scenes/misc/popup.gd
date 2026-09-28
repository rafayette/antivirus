extends TextureRect

@export var variants: Array[Texture2D] = []
@export var adware: Enemy

func adware_removing() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(0.1, 0.1), 0.5)
	tween.tween_property(self, "modulate:a", 0, 0.5)
	await tween.finished
	queue_free()

func _ready() -> void:
	if not adware or adware.is_dying:
		queue_free()
	var x = randf_range(0, 1152.0)
	var y = randf_range(0, 648.0)
	
	position.x = x
	position.y = y
	
	pivot_offset = size / 2.0
	
	texture = variants.pick_random()
	modulate.a = 0
	scale = Vector2(0.1, 0.1)
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(6.0, 6.0), 0.5)
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	
	adware.dying.connect(adware_removing)
	
