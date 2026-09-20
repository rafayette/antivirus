extends CanvasLayer

@onready var melt_rect: TextureRect = $MeltRect
var target_scene: String = ""
var current_tween: Tween = null

func change_scene(scene_path: String) -> void:
	# cancel any transition already in progress
	if current_tween and current_tween.is_valid():
		current_tween.kill()
	
	target_scene = scene_path
	
	var img: Image = get_viewport().get_texture().get_image()
	var screenshot := ImageTexture.create_from_image(img)
	
	melt_rect.texture = screenshot
	melt_rect.visible = true
	var mat: ShaderMaterial = melt_rect.material
	mat.set_shader_parameter("melt_progress", 0.0)
	
	get_tree().change_scene_to_file(target_scene)
	
	current_tween = create_tween()
	current_tween.tween_method(_set_melt, 0.0, 1.0, 1.2)
	current_tween.tween_callback(func(): melt_rect.visible = false)

func _set_melt(value: float) -> void:
	var mat: ShaderMaterial = melt_rect.material
	mat.set_shader_parameter("melt_progress", value)
