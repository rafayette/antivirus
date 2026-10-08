extends CharacterBody3D
class_name Player

var SPEED := 7.0
const ACCEL = 3.0
const FRICTION = 1.8
@export var temperaturePerTick = 0
var timer = 0.0
var over_clocking = false
@export var looking_back = false

@export var joystick_turn_speed := 6
@export var fighting_boss = false
@export var has_key = false
@export var temperature = 40.0
@export var ram = 100.0
@onready var damageCheck = $DamageCheck
@onready var ui_layer: CanvasLayer = $"../UI"
@onready var statusBar: ShaderMaterial = $"../UI/StatusBar".material
@onready var statusBarBackground: ShaderMaterial = $"../UI/StatusBarBackground".material
@onready var weapon_sprite: ShaderMaterial = $"../UI/Weapon".material
@onready var temperatureBar = $"../UI/TemperatureProgressBar"
@onready var item_label: Label = $"../UI/ItemLabel"
@onready var ramBar = $"../UI/RamProgressBar"
@onready var overheatLabel = $"../UI/OverheatWarning"
@onready var shaderRect = $"../PostProcessing/ColorRect"
@onready var camera = $Camera3D

@onready var overheatSfx = $"../SoundEffects/OverheatAlert"
@onready var gameOverSfx = $"../SoundEffects/GameOver"
@onready var gameOverBossSfx = $"../SoundEffects/GameOverBoss"
@onready var scanSfx = $"../SoundEffects/Scan"
@onready var itemPickupSfx = $"../SoundEffects/Item"
@onready var bombSfx = $"../SoundEffects/Bomb"

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	shaderRect.material.set_shader_parameter("pixel_size", 2)

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var horizontal_velocity := Vector3(velocity.x, 0, velocity.z)
	var target_velocity := direction * SPEED
	
	if direction != Vector3.ZERO:
		horizontal_velocity = horizontal_velocity.move_toward(target_velocity, ACCEL * delta * SPEED)
	else:
		horizontal_velocity = horizontal_velocity.move_toward(Vector3.ZERO, FRICTION * delta * SPEED)
	
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	
	move_and_slide()

func toggle_overclock(toggle: bool) -> void:
	if toggle == true:
		over_clocking = true
		SPEED = 10.0
		temperaturePerTick += 0.2
	else:
		over_clocking = false
		SPEED = 7.0
		temperaturePerTick -= 0.2

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("look_back"):
		looking_back = true
		camera.rotation.y += PI
	elif event.is_action_released("look_back"):
		camera.rotation.y -= PI
		looking_back = false
	if event.is_action_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if event.is_action_pressed("overclock") and not over_clocking:
		toggle_overclock(true)
	elif event.is_action_released("overclock") and over_clocking:
		toggle_overclock(false)
	if event.is_action_pressed("scan"):
		cast_scan_pulse(global_position)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * 0.003)

func check_camera(delta: float) -> void:
	var camera_dir := Input.get_axis("turn_left", "turn_right")
	var intensity = -camera_dir
	rotate_y(joystick_turn_speed * intensity * delta)

func _process(delta: float):
	check_camera(delta)
	var input_dir := Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if ram <= 100.0 and not over_clocking:
		ram = min(100.0, ram + (delta * 10))
	ramBar.value = ram
	var increase = temperaturePerTick * delta * 60
	temperature = min(temperature + increase, 140.0)
	if is_zero_approx(increase):
		var decrease = 0.05
		if direction == Vector3.ZERO:
			decrease = 0.2
		temperature = maxf(40.0, temperature - decrease * delta * 60)
		camera.h_offset = 0
		camera.v_offset = 0
		ui_layer.offset = Vector2.ZERO
	else:
		var offset = Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1),
		) * temperaturePerTick * 0.1
		
		#ui_layer.offset.x = offset.x * 300
		#ui_layer.offset.y = offset.y * 300
		camera.h_offset = offset.x
		camera.v_offset = offset.y
		
	var percentage = (temperature - 40.0) / 90.0
	statusBar.set_shader_parameter("heat_shift", percentage)
	statusBarBackground.set_shader_parameter("heat_shift", percentage)
	weapon_sprite.set_shader_parameter("heat_shift", percentage)
	shaderRect.material.set_shader_parameter("temperature", temperature)
	temperatureBar.value = percentage * 100
	
	if temperature >= 130.0:
		timer += delta
		overheatLabel.modulate.a = sin(timer * 6)
		if sin(timer * 6) > 0.95:
			if not overheatSfx.playing:
				overheatSfx.play()
	else:
		overheatLabel.modulate.a = 0.0
		if timer > 0.0:
			timer = maxf(0.0, timer - delta)
		
	if timer >= 5.0:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if fighting_boss:
			$"../GameOverBoss".visible = true
			$"../UI".visible = false
			gameOverBossSfx.play()
		else:
			$"../GameOver".visible = true
			$"../UI".visible = false
			gameOverSfx.play()
		shaderRect.material.set_shader_parameter("pixel_size", 20)
		get_tree().paused = true

func item_picked_up(label, isBomb) -> void:
	if isBomb:
		bombSfx.play()
	else:
		itemPickupSfx.play()
	item_label.text = label
	item_label.modulate.a = 1
	var tween := create_tween()
	#tween.set_trans(Tween.TRANS_BACK)
	#tween.set_parallel(true)
	#tween.tween_property(self, "scale", Vector2(0.1, 0.1), 0.5)
	tween.tween_property(item_label, "modulate:a", 0, 1)

func _on_damage_check_body_entered(body: Node3D) -> void:
	if body is Item:
		body.pick_up(self)
	elif body is Enemy:
		temperaturePerTick += body.temperature_per_tick

func _on_damage_check_body_exited(body: Node3D) -> void:
	if body is Enemy:
		temperaturePerTick = maxf(0.0, temperaturePerTick - body.temperature_per_tick)

var scanning = false
func cast_scan_pulse(origin: Vector3, max_radius: float = 60.0, duration: float = 2.5) -> void:
	if ram < 60.0 or scanning:
		return
	ram -= 60.0
	scanning = true
	scanSfx.play()
	var plane := MeshInstance3D.new()
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(200, 200)
	plane.mesh = mesh
	
	var mat := ShaderMaterial.new()
	mat.shader = load("res://shaders/scan.gdshader")
	mat.set_shader_parameter("pulse_origin", origin)
	mat.set_shader_parameter("band_width", 1.5)
	plane.material_override = mat
	
	get_tree().current_scene.add_child(plane)
	plane.global_position = Vector3(origin.x, origin.y - 0.9, origin.z)
	
	var already_tagged: Array = []
	var current_radius: float = 0.0
	
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_method(func(v):
		current_radius = v
		mat.set_shader_parameter("wave_radius", v)
		_tag_enemies_in_radius(origin, current_radius, already_tagged)
	, 0.0, max_radius, duration)
	tween.tween_method(func(v): mat.set_shader_parameter("alpha_fade", v), 1.0, 0.0, duration)
	tween.chain().tween_callback(plane.queue_free)
	scanning = false

func _tag_enemies_in_radius(origin: Vector3, radius: float, already_tagged: Array) -> void:
	for enemy in get_tree().get_nodes_in_group("entity"):
		if enemy in already_tagged:
			continue
		if origin.distance_to(enemy.global_position) <= radius:
			already_tagged.append(enemy)
			if enemy.has_method("mark_as_scanned"):
				enemy.mark_as_scanned()
