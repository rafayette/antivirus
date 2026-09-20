extends Node

@onready var title_ui = $TitleUI
@onready var post_processing = $PostProcessing
@export var visible = false

func _process(delta: float) -> void:
	title_ui.visible = self.visible
	post_processing.visible = self.visible
