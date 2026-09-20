extends CanvasLayer

@onready var splash_texture: TextureRect = $Splash

func go_to_title() -> void:
	ScreenTransition.change_scene("res://scenes/misc/title_screen.tscn")

func _ready() -> void:
	splash_texture.modulate.a = 0
	var tween := create_tween()
	tween.tween_property(splash_texture, "modulate:a", 1.0, 0.5)
	await tween.finished
	await get_tree().create_timer(1).timeout
	tween = create_tween()
	tween.tween_property(splash_texture, "modulate:a", 0.0, 0.5)
	await tween.finished
	go_to_title()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("accept"):
		go_to_title()
