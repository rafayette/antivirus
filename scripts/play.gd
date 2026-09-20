extends Label

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse and event.is_pressed():
		ScreenTransition.change_scene("res://scenes/levels/level_1.tscn")
