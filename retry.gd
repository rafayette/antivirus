extends Label

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse and event.is_pressed():
		get_tree().paused = false
		get_tree().reload_current_scene()
