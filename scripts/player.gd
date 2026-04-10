extends CharacterBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera: Camera3D = $Camera3D
@onready var light: SpotLight3D = $Camera3D/SpotLight3D   # ✅ FIXED TYPE
@onready var tourch: Node3D = $Camera3D/light

@export var speed: float = 6.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.002
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var max_health: float = 100.0

var pitch: float = 0.0
var is_light_on := false
var health: float = 100.0
var current_speed: float = 6.0
var damage_slow_timer: float = 0.0
const SLOW_DURATION_NORMAL := 1.0
const SLOW_DURATION_LOW    := 2.0
const SLOW_SPEED_NORMAL    := 0.40
const SLOW_SPEED_LOW       := 0.20

# Inventory — each entry is a Dictionary with keys:
# name, icon (res:// path or ""), usable, quantity, effect
var inventory: Array[Dictionary] = []

const LIGHT_POWER := 2.586   # ✅ Your required value

signal health_changed(new_health, max_health)
signal player_died
signal player_won

var has_won := false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	animation_player.play("idle")
	
	# Start with light OFF
	light.light_energy = 0.0
	
	# Add player to group so enemies can find it
	add_to_group("player")
	
	# Initialize health
	health = max_health
	current_speed = speed
	health_changed.emit(health, max_health)

	# Starter items
	add_item({"name": "Bandage", "icon": "", "usable": true, "quantity": 2, "effect": "heal", "value": 25.0})
	add_item({"name": "Torch", "icon": "", "usable": false, "quantity": 1, "effect": "", "value": 0.0})
	

func _unhandled_input(event):

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)

		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, deg_to_rad(-89), deg_to_rad(89))
		camera.rotation.x = pitch


	# ESC is handled by the pause menu


func _input(event):
	# Only recapture mouse on click when no UI menus are open
	if event is InputEventMouseButton and event.pressed:
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			var pause_open = get_tree().get_first_node_in_group("pause_menu_open")
			var bag_open = get_tree().get_first_node_in_group("backpack_open")
			var info_open = get_tree().get_first_node_in_group("info_open")
			if not pause_open and not bag_open and not info_open:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):

	# Recover speed after damage slow
	if damage_slow_timer > 0.0:
		damage_slow_timer -= delta
		if damage_slow_timer <= 0.0:
			current_speed = speed

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
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)


	# ✅ LIGHT TOGGLE (Energy Control)
	if Input.is_action_just_pressed("toggle_light"):
		is_light_on = !is_light_on

		if is_light_on:
			light.light_energy = LIGHT_POWER   # ON
		else:
			light.light_energy = 0            # OFF


	move_and_slide()

	if not has_won:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider is CSGBox3D and collider.name == "CSGBox3D":
				has_won = true
				player_won.emit()
				break

	_update_animation()



func _update_animation():

	var horizontal_speed = Vector2(velocity.x, velocity.z).length()

	if horizontal_speed > 0.1 and is_on_floor():
		if animation_player.current_animation != "run":
			animation_player.play("run")
	else:
		if animation_player.current_animation != "idle":
			animation_player.play("idle")
			
			


func add_item(item: Dictionary):
	# Stack if same name already exists
	for existing in inventory:
		if existing["name"] == item["name"]:
			existing["quantity"] += item.get("quantity", 1)
			return
	inventory.append(item)

func use_item(item: Dictionary):
	if item.get("effect") == "heal":
		heal(item.get("value", 20.0))
	item["quantity"] -= 1
	if item["quantity"] <= 0:
		inventory.erase(item)

func take_damage(amount: float):
	if health <= 0:
		return

	health -= amount
	health = max(0, health)
	health_changed.emit(health, max_health)

	# Apply speed slow — deeper and longer when health is low
	var pct = health / max_health
	if pct < 0.40:
		current_speed = speed * SLOW_SPEED_LOW
		damage_slow_timer = SLOW_DURATION_LOW
	else:
		current_speed = speed * SLOW_SPEED_NORMAL
		damage_slow_timer = SLOW_DURATION_NORMAL

	if health <= 0:
		die()

func heal(amount: float):
	health += amount
	health = min(health, max_health)
	health_changed.emit(health, max_health)
	print("Player healed ", amount, ". Health: ", health, "/", max_health)

func die():
	player_died.emit()
	set_physics_process(false)
	set_process_unhandled_input(false)
