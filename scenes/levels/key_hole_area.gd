extends Area3D

@export var next_level: PackedScene
@export var boss_scene: PackedScene
@export var is_boss = false
@export var boss_spawned = false

func transition():
	ScreenTransition.change_scene(next_level.resource_path, true)
func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		if body.has_key == true:
			if is_boss:
				if boss_spawned == false:
					body.has_key = false
					var boss: Node3D = boss_scene.instantiate()
					get_tree().current_scene.add_child(boss)
					boss.global_position = $"../BossSpawnPoint".global_position
					$"../MeshInstance3D".visible = false
					$"../SoundEffects/BossSpawn".play()
					$"../BossMusic".play()
					boss_spawned = true
					body.fighting_boss = true
				elif body.has_key == true:
					Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
					call_deferred("transition")
					ScreenTransition.counting = false
			elif next_level:
				call_deferred("transition")
