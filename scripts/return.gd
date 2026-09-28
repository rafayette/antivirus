extends Label

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse and event.is_pressed():
		get_tree().paused = false
		ScreenTransition.change_scene("res://scenes/misc/title_screen.tscn")
