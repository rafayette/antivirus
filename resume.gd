extends Label

@onready var pause_screen = $"../../.."

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse and event.is_pressed():
		pause_screen.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_tree().paused = false
