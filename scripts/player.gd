extends CharacterBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera: Camera3D = $Camera3D
@onready var light: SpotLight3D = $Camera3D/SpotLight3D   # ✅ FIXED TYPE
@onready var tourch: Node3D = $Camera3D/light

@export var speed: float = 8.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.002
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var pitch: float = 0.0
var is_light_on := false

const LIGHT_POWER := 2.586   # ✅ Your required value

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	animation_player.play("idle")
	
	# Start with light OFF
	light.light_energy = 0.0
	

func _unhandled_input(event):

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)

		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, deg_to_rad(-89), deg_to_rad(89))
		camera.rotation.x = pitch


	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):

	if event is InputEventMouseButton and event.pressed:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta


	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity


	# Movement
	var input_dir = Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_back"
	)

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)


	# ✅ LIGHT TOGGLE (Energy Control)
	if Input.is_action_just_pressed("toggle_light"):
		is_light_on = !is_light_on

		if is_light_on:
			light.light_energy = LIGHT_POWER   # ON
		else:
			light.light_energy = 0            # OFF


	move_and_slide()

	_update_animation()



func _update_animation():

	var horizontal_speed = Vector2(velocity.x, velocity.z).length()

	if horizontal_speed > 0.1 and is_on_floor():
		if animation_player.current_animation != "run":
			animation_player.play("run")
	else:
		if animation_player.current_animation != "idle":
			animation_player.play("idle")
			
			
