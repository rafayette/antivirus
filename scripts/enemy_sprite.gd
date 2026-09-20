@tool
extends AnimatedSprite3D

var dissolve_material: ShaderMaterial
var wave_time = 0.0

func _update_facing_sprite() -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if not camera:
		return
	
	var to_camera: Vector3 = camera.global_position - global_position
	to_camera.y = 0.0
	to_camera = to_camera.normalized()
	
	var enemy_forward: Vector3 = -global_transform.basis.z
	enemy_forward.y = 0.0
	enemy_forward = enemy_forward.normalized()
	
	var angle: float = enemy_forward.signed_angle_to(to_camera, Vector3.UP)
	var abs_angle_deg: float = abs(rad_to_deg(angle))
	
	flip_h = angle > 0.0  # flipped condition
	
	if abs_angle_deg < 22.5:
		animation = "forward"
	elif abs_angle_deg < 67.5:
		animation = "half_left"
	elif abs_angle_deg < 135.0:
		animation = "full_left"
	else:
		animation = "backward"

func _ready() -> void:
	dissolve_material = material_override
	frame_changed.connect(_update_shader_texture)
	animation_changed.connect(_update_shader_texture)
	_update_shader_texture()  # set it once immediately for the starting frame

func _update_shader_texture() -> void:
	var current_texture: Texture2D = sprite_frames.get_frame_texture(animation, frame)
	dissolve_material.set_shader_parameter("albedo_texture", current_texture)

func _process(delta: float) -> void:
	wave_time += delta
	var wave = sin(wave_time * 2)
	position.y = abs(wave * 0.5)
