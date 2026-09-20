extends Label

@onready var pause_screen = $"../../PauseScreen"

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse and event.is_pressed():
		get_tree().paused = false
		get_tree().reload_current_scene()

func _input(event: InputEvent) -> void:
	if event.is_action("pause") and event.is_pressed():
		if get_tree().paused == true:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			pause_screen.visible = false
			get_tree().paused = false
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			pause_screen.visible = true
			get_tree().paused = true
