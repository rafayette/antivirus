extends Node3D

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action("pause") and event.is_pressed():
		if get_tree().paused == true:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_tree().paused = false
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_tree().paused = true
