extends Node

@export var enemy_spawners: Array[Node] = []
@export var key_scene: PackedScene
@export var key_spawned: bool = false

func check_for_level_complete(death_position: Vector3) -> void:
	if key_spawned:
		return
	
	for spawner in enemy_spawners:
		if not spawner.is_finished_spawning():
			return
	
	var enemy_count: int = get_tree().get_nodes_in_group("enemy").size()
	#var item_count: int = get_tree().get_nodes_in_group("item").size()
	var remaining: int = enemy_count# - item_count
	#print("Enemy count: " + str(enemy_count) + "/Item count: " + str(item_count) + "Remaining: " + str(remaining))
	#print(remaining)
	if remaining > 0:
		return
	
	key_spawned = true
	var key: Node3D = key_scene.instantiate()
	get_tree().current_scene.add_child(key)
	key.global_position = death_position
	var music: AudioStreamPlayer = get_tree().get_first_node_in_group("music")
	if not music:
		music = $Music
	if music:
		music.stop()
