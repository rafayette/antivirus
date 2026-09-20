extends Node

@export var enemy_scene: PackedScene
@export var max_enemies: int = 10
@export var check_interval: float = 2.0
@export var spawn_points: Array[Marker3D] = []

@onready var timer: Timer = $Timer
@onready var camera: Camera3D = get_viewport().get_camera_3d()

func _ready() -> void:
	for child in get_children():
		if child is Marker3D:
			spawn_points.append(child)
	timer.wait_time = check_interval
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	var current_enemy_count: int = get_tree().get_nodes_in_group("enemy").size()
	if current_enemy_count < max_enemies:
		_spawn_enemy()

func _spawn_enemy() -> void:
	var valid_points: Array[Marker3D] = spawn_points.filter(_is_point_hidden)
	if valid_points.is_empty():
		return  # every spawn point is currently visible, skip this cycle

	var spawn_point: Marker3D = valid_points[randi() % valid_points.size()]
	var enemy: Node3D = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = spawn_point.global_position

func _is_point_hidden(point: Node3D) -> bool:
	if not camera:
		return true
	return not camera.is_position_in_frustum(point.global_position)
