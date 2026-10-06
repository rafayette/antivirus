extends GridMap
enum Directions {HORIZONTAL, VERTICAL, DIAGONAL}
@export var direction = Directions.VERTICAL
@onready var grid = $"."
@onready var environment: Environment = $"../WorldEnvironment".environment
var mat: StandardMaterial3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mesh_lib: MeshLibrary = grid.mesh_library
	var mesh: Mesh = mesh_lib.get_item_mesh(0)
	mat = mesh.surface_get_material(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if mat:
		if direction == Directions.VERTICAL:
			mat.uv1_offset.y += delta * 0.5
		elif direction == Directions.HORIZONTAL:
			mat.uv1_offset.x += delta * 0.5
			mat.uv1_offset.z -= delta * 0.5
		elif direction == Directions.DIAGONAL:
			mat.uv1_offset.x += delta * 0.5
			mat.uv1_offset.z -= delta * 0.5
			mat.uv1_offset.y -= delta * 0.5
		environment.sky_rotation.y += delta * 0.05
