extends Enemy

var ad_timer = 0.0
var popup_scene = preload("res://scenes/misc/popup.tscn")
@onready var popup_ui: CanvasLayer = get_tree().get_first_node_in_group("popup_ui")

func _ready() -> void:
	sprite = $AnimatedSprite3D
	temperature_per_tick = 0.3
	#speed = 0.0
	chases_player = false

func _process(delta: float) -> void:
	add_to_group("entity")
	global_position.y = 1.2
	var distance = global_position.distance_to(player.global_position)
	if distance < 15.0:
		var intensity = 1.0 - (distance / 15.0)  # 0.0 to 1.0
		ad_timer += delta * intensity
		if ad_timer >= 1.0:
			ad_timer = 0.0
			var newPopup = popup_scene.instantiate()
			newPopup.adware = self
			popup_ui.add_child(newPopup)
	else:
		ad_timer = 0.0
