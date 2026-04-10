extends Node3D

# Add this as a child of Enemy to visualize vision cone
# Attach to a MeshInstance3D node

@export var show_vision_cone: bool = true
@export var vision_range: float = 12.0
@export var vision_angle: float = 140.0

var enemy: CharacterBody3D

func _ready():
	enemy = get_parent()
	if show_vision_cone:
		_create_vision_cone()

func _create_vision_cone():
	var mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	
	# Create a simple cone mesh
	var immediate_mesh = ImmediateMesh.new()
	mesh_instance.mesh = immediate_mesh
	
	# Material for the cone
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1, 1, 0, 0.2)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh_instance.material_override = material

func _process(_delta):
	if show_vision_cone and enemy:
		queue_redraw()

func _draw():
	pass  # 3D drawing happens in _process
