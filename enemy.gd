class_name Enemy
extends CharacterBody3D

@export var temperature_per_tick: float
@export var speed: float = 7.0
@onready var player: Node3D = get_tree().get_first_node_in_group("player")
@onready var raycast: RayCast3D = $RayCast3D
var target_velocity: Vector3

func _physics_process(delta: float) -> void:
	_update_target()
	_move(delta)

func _update_target() -> void:
	var lookat: Vector3 = player.position - global_position
	raycast.target_position = lookat
	if raycast.is_colliding():
		var object_colliding = raycast.get_collider()
		if object_colliding == player:
			target_velocity = lookat

func _move(delta: float) -> void:
	var horizontal_velocity: Vector3 = Vector3(velocity.x, 0, velocity.z).move_toward(target_velocity, delta * speed)
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	move_and_slide()
