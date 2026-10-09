extends Label

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse and event.is_pressed():
		var current_locale : String = TranslationServer.get_locale()
		if current_locale.begins_with("pt"):
			TranslationServer.set_locale("en")
		else:
			TranslationServer.set_locale("pt_BR")
