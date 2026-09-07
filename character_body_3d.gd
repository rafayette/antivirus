extends CharacterBody3D

const SPEED = 7.0
const ACCEL = 3.0
const FRICTION = 1.8
var temperaturePerTick = 0

@export var temperature = 40.0
@onready var damageCheck = $DamageCheck
@onready var temperatureLabel = $"../UI/Temperature"
@onready var shaderRect = $"../PostProcessing/ColorRect"
@onready var camera = $Camera3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

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

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("look_back"):
		camera.rotation.y += PI
	elif event.is_action_released("look_back"):
		camera.rotation.y -= PI

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.003)

func _process(delta: float):
	var input_dir := Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var increase = temperaturePerTick * delta * 60
	temperature += increase
	if is_zero_approx(increase):
		var decrease = 0.05
		if direction == Vector3.ZERO:
			decrease = 0.2
		temperature = maxf(40.0, temperature - decrease * delta * 60)
	temperatureLabel.text = str(floor(temperature)) + "*C"
	shaderRect.material.set_shader_parameter("temperature", temperature)

func _on_damage_check_body_entered(body: Node3D) -> void:
	if body is Enemy:
		temperaturePerTick += body.TemperaturePerTick

func _on_damage_check_body_exited(body: Node3D) -> void:
	if body is Enemy:
		temperaturePerTick = maxf(0.0, temperaturePerTick - body.TemperaturePerTick)
