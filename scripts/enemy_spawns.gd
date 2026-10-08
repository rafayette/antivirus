extends Node

@export var enabled := true
@export var enemy_scene: PackedScene
@export var max_enemies: int = 10
@export var total_enemies_to_spawn: int = 20
@export var check_interval: float = 2.0
@export var spawn_points: Array[Marker3D] = []
@export var is_item = false
@export var min_item_distance: float = 3.0

@onready var timer: Timer = $Timer
@onready var camera: Camera3D = get_viewport().get_camera_3d()

var total_spawned: int = 0

func is_finished_spawning() -> bool:
	if not enabled:
		return true
	
	return total_enemies_to_spawn > 0 and total_spawned >= total_enemies_to_spawn

func _ready() -> void:
	if not enabled:
		return
	for child in get_children():
		if child is Marker3D:
			spawn_points.append(child)
	timer.wait_time = check_interval
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	if total_enemies_to_spawn > 0 and total_spawned >= total_enemies_to_spawn:
		return
	
	var current_enemy_count: int = get_tree().get_nodes_in_group("enemy").size()
	if is_item == true:
		current_enemy_count = get_tree().get_nodes_in_group("item").size()
	
	if current_enemy_count < max_enemies:
		_spawn_enemy()

func _spawn_enemy() -> void:
	var valid_points: Array[Marker3D] = spawn_points.filter(_is_point_hidden)
	
	if is_item:
		valid_points = valid_points.filter(_is_point_far_from_items)
	
	if valid_points.is_empty():
		return

	var spawn_point: Marker3D = valid_points[randi() % valid_points.size()]
	var enemy: Node3D = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = spawn_point.global_position
	total_spawned += 1

func _is_point_hidden(point: Node3D) -> bool:
	if not camera:
		return true
	return not camera.is_position_in_frustum(point.global_position)

func _is_point_far_from_items(point: Node3D) -> bool:
	var existing_items: Array = get_tree().get_nodes_in_group("item")
	for item in existing_items:
		if point.global_position.distance_to(item.global_position) < min_item_distance:
			return false
	return true
