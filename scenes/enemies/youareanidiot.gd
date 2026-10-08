extends Enemy

@export var clone_scene: PackedScene
@onready var explosion_sfx = $ExplosionSFX
@onready var sky_mat: ShaderMaterial = $"../WorldEnvironment".environment.sky.sky_material

func death_effect() -> void:
	sprite.play("death")
	shake_sprite(2.5, 0.3)
	play_repeating_explosions(3)
	
	is_dying = true
	set_physics_process(false)
	var col_shape := $CollisionShape3D
	col_shape.disabled = true
	
	var tween := create_tween()
	tween.tween_method(_set_dissolve, 0.0, 0.5, 3)
	tween.tween_callback(on_death_finished)

func play_repeating_explosions(total_duration: float) -> void:
	var explosion_interval: float = 0.15
	var explosion_count: int = int(total_duration / explosion_interval)
	
	for i in range(explosion_count):
		if is_instance_valid(self):
			explosion_sfx.volume_db -= 0.6
			explosion_sfx.play()
			sprite.scale += (Vector3.ONE * 0.7)
		await get_tree().create_timer(explosion_interval).timeout

func shake_sprite(duration: float, strength: float) -> void:
	var original_pos: Vector3 = sprite.position
	var shake_tween := create_tween()
	var shake_count: int = 200
	for i in range(shake_count):
		var offset := Vector3(randf_range(-strength, strength), randf_range(-strength, strength), 0.0)
		shake_tween.tween_property(sprite, "position", original_pos + offset, duration / shake_count)
	shake_tween.tween_property(sprite, "position", original_pos, 0.05)

func on_death_finished() -> void:
	var level_manager: Node = get_tree().get_first_node_in_group("level_manager")
	if level_manager:
		level_manager.key_spawned = false
		level_manager.check_for_level_complete(global_position)
	$"../MeshInstance3D".visible = true
	queue_free()

func _process(_delta: float) -> void:
	global_position.y = 1.867

func spawn_clones(amount: int) -> void:
	for i in range(amount):
		var spawn_pos: Vector3 = find_valid_clone_position()
		if spawn_pos == Vector3.INF:
			continue 
		
		var clone: Node3D = clone_scene.instantiate()
		get_tree().current_scene.add_child(clone)
		clone.global_position = spawn_pos
		clone.global_position.y = 1.2

func find_valid_clone_position(max_attempts: int = 8) -> Vector3:
	var space_state := get_world_3d().direct_space_state
	
	for attempt in range(max_attempts):
		var offset := Vector3(randf_range(-2.5, 2.5), 0.0, randf_range(-2.5, 2.5))
		var candidate: Vector3 = global_position + offset
		
		var query := PhysicsRayQueryParameters3D.create(global_position, candidate)
		query.collision_mask = 1
		var result: Dictionary = space_state.intersect_ray(query)
		
		if result.is_empty():
			return candidate
	
	return Vector3.INF

func damage_effect() -> void:
	sprite.play("damage")
	$DamageSFX.play()
	$CloneSFX.play()
	if health >= 5:
		speed += 0.7
		true_speed += 0.7
		spawn_clones(min(max_health - health, 5))
		sky_mat.set_shader_parameter("reveal_amount", (float(health) - 5.0) / 10.0)
		
		#print("Max health: " + str(max_health) = "/Health: " + str(health))
	else:
		speed = 0.5
		true_speed = 0.5
		temperature_per_tick = 0.0
		sky_mat.set_shader_parameter("reveal_amount", 0.0)

func _ready() -> void:
	add_to_group("entity")
	sprite = $AnimatedSprite3D
	temperature_per_tick = 3
	health = max_health
	var tween := create_tween()
	tween.tween_method(func(v): sky_mat.set_shader_parameter("reveal_amount", v), 0.0, 1.0, 1.5)
