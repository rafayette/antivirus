class_name Enemy
extends CharacterBody3D

@export var temperature_per_tick: float
@export var sprite: AnimatedSprite3D
@export var speed: float = 7.0
@export var max_health: int = 1
@export var chases_player := true
signal dying

@onready var player: Node3D = get_tree().get_first_node_in_group("player")
@onready var raycast: RayCast3D = $RayCast3D
@onready var camera: Camera3D = get_viewport().get_camera_3d()
var target_velocity: Vector3
var health: int
var is_dying: bool = false
var dissolve_material: ShaderMaterial

func _physics_process(delta: float) -> void:
	_update_target()
	_move(delta)

func _update_target() -> void:
	var lookat: Vector3 = player.position - global_position
	raycast.target_position = lookat
	if sprite:
		var cam_pos: Vector3 = camera.global_position
		cam_pos.y = global_position.y
		
		var to_camera: Vector3 = (cam_pos - global_position).normalized()
		var raw_angle: float = atan2(to_camera.x, to_camera.z)
		
		var step_count: int = 16
		var step_size: float = TAU / float(step_count)
		var snapped_angle: float = round(raw_angle / step_size) * step_size
		
		sprite.rotation.y = snapped_angle
	
	if raycast.is_colliding():
		var object_colliding = raycast.get_collider()
		if object_colliding == player:
			target_velocity = lookat

func _move(delta: float) -> void:
	if not chases_player:
		return
	var horizontal_velocity: Vector3 = Vector3(velocity.x, 0, velocity.z).move_toward(target_velocity, delta * speed)
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	move_and_slide()

func _ready() -> void:
	health = max_health
	
	dissolve_material = sprite.material_override
	#sprite.material_override = dissolve_material
	add_to_group("enemy")

func take_damage(amount: int) -> void:
	if is_dying:
		return
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	var xray_material: ShaderMaterial = sprite.material_overlay
	xray_material.set_shader_parameter("highlight_strength", 0.0)
	is_dying = true
	dying.emit()
	set_physics_process(false)
	var col_shape := $CollisionShape3D
	col_shape.disabled = true
	
	$DeathSFX.play()
	
	var tween := create_tween()
	tween.tween_method(_set_dissolve, 0.0, 0.5, 0.8)
	tween.tween_callback(queue_free)

func _set_dissolve(value: float) -> void:
	var material: ShaderMaterial = sprite.material_override
	material.set_shader_parameter("dissolve_progress", value)

func mark_as_scanned() -> void:
	var xray_material: ShaderMaterial = sprite.material_overlay
	xray_material.set_shader_parameter("highlight_strength", 0.0)
	
	var tween := create_tween()
	tween.tween_method(func(v): xray_material.set_shader_parameter("highlight_strength", v), 0.0, 1.0, 0.1)
	tween.tween_interval(3.0)
	tween.tween_method(func(v): xray_material.set_shader_parameter("highlight_strength", v), 1.0, 0.0, 0.5)
