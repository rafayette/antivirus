extends CanvasLayer

@export var counting := false
var time_elapsed := 0.0
var target_scene: String = ""
var current_tween: Tween = null

@onready var melt_rect: TextureRect = $MeltRect
@onready var timer: RichTextLabel = $Timer

func reset_timer():
	time_elapsed = 0.0

func _process(delta: float) -> void:
	if counting == true:
		time_elapsed += delta
	
	timer.text = format_time(time_elapsed)

func format_time(time: float) -> String:
	var minutes = int(time / 60)
	var seconds = int(time) % 60
	var milliseconds = int((time - int(time)) * 100)
	
	return "%02d:%02d:%02d" % [minutes, seconds, milliseconds]

func change_scene(scene_path: String, play_sfx: bool = false) -> void:
	
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
	if play_sfx:
		$SFX.play()
	
	current_tween = create_tween()
	current_tween.tween_method(_set_melt, 0.0, 1.0, 1.2)
	current_tween.tween_callback(func(): melt_rect.visible = false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_timer"):
		timer.visible = not timer.visible

func _set_melt(value: float) -> void:
	var mat: ShaderMaterial = melt_rect.material
	mat.set_shader_parameter("melt_progress", value)
