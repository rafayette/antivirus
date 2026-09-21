extends Camera3D

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")
@export var damage: float = 25.0
@export var shoot_range: float = 100.0
@export var return_speed: float = 8.0
@onready var camera: Camera3D = get_viewport().get_camera_3d()
@onready var weapon_sprite: AnimatedSprite2D = $"../../UI/Weapon"
var base_y: float
var bob_time := 0.0
@export var bob_amount = 0.1
@export var bob_speed = 11

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		fire()

func _spawn_laser_visual(from: Vector3, to: Vector3) -> void:
	var laser := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.02
	mesh.bottom_radius = 0.02
	mesh.height = from.distance_to(to)
	laser.mesh = mesh
	
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.6, 1.0)
	mat.emission_enabled = true
	mat.emission = Color(0.2, 0.6, 1.0)
	mat.emission_energy = 3.0
	laser.material_override = mat
	
	get_tree().current_scene.add_child(laser)
	laser.global_position = from.lerp(to, 0.5)
	laser.look_at(to, Vector3.UP)
	laser.rotate_object_local(Vector3.RIGHT, PI / 2.0)  # cylinder default axis correction
	
	var tween := create_tween()
	tween.tween_property(laser, "scale", Vector3(0.1, 1.0, 0.1), 0.08)
	tween.tween_callback(laser.queue_free)

func fire() -> void:
	if weapon_sprite.is_playing():
		return
	if player.ram < 15.0:
		return
	player.ram -= 15.0
	weapon_sprite.play("shoot")
	$ShootSFX.play()
	var space_state := get_world_3d().direct_space_state
	var muzzle_offset: float = 0.3  # start the visual slightly ahead of the camera
	var from: Vector3 = camera.global_position + camera.global_transform.basis.z * -muzzle_offset
	var to: Vector3 = camera.global_position + camera.global_transform.basis.z * -shoot_range
	
	var query := PhysicsRayQueryParameters3D.create(from, to, 0b110)
	query.collide_with_bodies = true
	
	var result: Dictionary = space_state.intersect_ray(query)
	
	_spawn_laser_visual(from, result.get("position", to))
	
	if result and result.collider.is_in_group("enemy"):
		result.collider.take_damage(damage)

func _ready() -> void:
	base_y = position.y

func _process(delta: float) -> void:
	var horizontal_speed: float = Vector2(player.velocity.x, player.velocity.z).length()
	var is_moving: bool = horizontal_speed > 0.1
	
	if is_moving:
		bob_time += delta * bob_speed
		var wave: float = sin(bob_time) * bob_amount
		position.y = lerp(position.y, base_y + wave, delta * 15.0)
	else:
		position.y = lerp(position.y, base_y, delta * return_speed)
