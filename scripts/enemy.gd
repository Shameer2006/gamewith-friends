extends CharacterBody3D

@export var health: float = 100.0
@export var max_health: float = 100.0
@export var move_speed: float = 5.0
@export var patrol_speed: float = 3.0
@export var attack_damage: float = 20.0
@export var attack_cooldown: float = 1.5
@export var search_distance: float = 12.0
@export var patrol_wait_time: float = 1.0
# Dungeon bounds — adjust these to match your GridMap extents
@export var dungeon_min: Vector3 = Vector3(-12, 0, -90)
@export var dungeon_max: Vector3 = Vector3(42, 0, 4)
@export var patrol_grid_step: float = 12.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var player: CharacterBody3D = null
var can_attack: bool = true
var is_dead: bool = false

var patrol_points: Array[Vector3] = []
var current_patrol_index: int = 0
var patrol_timer: float = 0.0
var is_waiting_at_patrol: bool = false

var last_player_direction: Vector3
var search_target: Vector3
var search_timer: float = 0.0
var max_search_time: float = 5.0

enum State { PATROL, CHASE, ATTACK, SEARCH }
var current_state: State = State.PATROL

@onready var vision_area: Area3D = $VisionArea
@onready var attack_area: Area3D = $AttackArea
@onready var mesh: MeshInstance3D = get_node_or_null("MeshInstance3D")
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	player = get_tree().get_first_node_in_group("player")

	

	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 0.5
	nav_agent.max_speed = move_speed
	nav_agent.avoidance_enabled = true

	vision_area.body_entered.connect(_on_vision_entered)
	vision_area.body_exited.connect(_on_vision_exited)
	attack_area.body_entered.connect(_on_attack_entered)
	attack_area.body_exited.connect(_on_attack_exited)

	# Defer so global_position is correct and NavigationServer has synced
	call_deferred("_deferred_setup")

func _deferred_setup():
	await get_tree().physics_frame
	_setup_patrol_points()
	if not patrol_points.is_empty():
		nav_agent.target_position = patrol_points[current_patrol_index]

func _setup_patrol_points():
	# Use manually placed Marker3D children if available
	for child in get_children():
		if child is Marker3D and child.name.begins_with("PatrolPoint"):
			patrol_points.append(child.global_position)

	if not patrol_points.is_empty():
		return

	# Auto-generate a grid of waypoints across the dungeon bounds
	# Uses a raycast downward to confirm the point is above solid floor
	var space = get_world_3d().direct_space_state
	var floor_y = global_position.y

	var x = dungeon_min.x
	while x <= dungeon_max.x:
		var z = dungeon_min.z
		while z <= dungeon_max.z:
			var probe = Vector3(x, floor_y + 2.0, z)
			var query = PhysicsRayQueryParameters3D.create(
				probe, probe + Vector3(0, -4, 0), 1
			)
			var result = space.intersect_ray(query)
			if result:
				patrol_points.append(result.position + Vector3(0, 0.1, 0))
			z += patrol_grid_step
		x += patrol_grid_step

	# Shuffle so the enemy doesn't always walk the same grid order
	patrol_points.shuffle()

	# Fallback if raycast found nothing (navmesh-only setup)
	if patrol_points.is_empty():
		var p = global_position
		patrol_points = [
			p + Vector3(10, 0, 0), p + Vector3(10, 0, 10),
			p + Vector3(0, 0, 10), p + Vector3(-10, 0, 0),
			p + Vector3(-10, 0, -10), p + Vector3(0, 0, -10),
		]

func _physics_process(delta):
	if is_dead:
		return

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	match current_state:
		State.PATROL:
			_do_patrol(delta)
		State.CHASE:
			_do_chase(delta)
		State.ATTACK:
			_do_attack(delta)
		State.SEARCH:
			_do_search(delta)

	move_and_slide()

func _do_patrol(delta):
	if patrol_points.is_empty():
		return

	var target = patrol_points[current_patrol_index]
	var dist = global_position.distance_to(target)

	if dist < 1.0:
		if not is_waiting_at_patrol:
			is_waiting_at_patrol = true
			patrol_timer = 0.0
			velocity.x = 0
			velocity.z = 0
		else:
			patrol_timer += delta
			if patrol_timer >= patrol_wait_time:
				_advance_patrol_point()
		return

	is_waiting_at_patrol = false
	_move_toward_position(delta, target, patrol_speed)

func _advance_patrol_point():
	current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
	is_waiting_at_patrol = false
	patrol_timer = 0.0
	nav_agent.target_position = patrol_points[current_patrol_index]

func _do_chase(delta):
	if not player:
		_return_to_patrol()
		return

	last_player_direction = (player.global_position - global_position).normalized()
	last_player_direction.y = 0

	nav_agent.target_position = player.global_position
	_move_toward_position(delta, player.global_position, move_speed)

func _do_search(delta):
	search_timer += delta

	if search_timer > max_search_time:
		_return_to_patrol()
		return

	var dist = global_position.distance_to(search_target)
	if dist < 1.0:
		_return_to_patrol()
		return

	_move_toward_position(delta, search_target, patrol_speed)

func _do_attack(delta):
	if not player:
		_return_to_patrol()
		return

	last_player_direction = (player.global_position - global_position).normalized()
	last_player_direction.y = 0

	velocity.x = 0
	velocity.z = 0

	var look_target = player.global_position
	look_target.y = global_position.y
	if look_target != global_position:
		var target_basis = global_transform.looking_at(look_target, Vector3.UP).basis
		global_transform.basis = global_transform.basis.slerp(target_basis, delta * 8.0)

	if can_attack:
		_perform_attack()

func _move_toward_position(delta: float, target: Vector3, speed: float):
	# Try navigation path first; fall back to direct movement if navmesh unavailable
	var next_pos: Vector3
	nav_agent.target_position = target

	if not nav_agent.is_navigation_finished() and nav_agent.get_next_path_position() != global_position:
		next_pos = nav_agent.get_next_path_position()
	else:
		next_pos = target

	var direction = (next_pos - global_position)
	direction.y = 0
	if direction.length() < 0.01:
		velocity.x = 0
		velocity.z = 0
		return

	direction = direction.normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	var look_target = global_position + direction
	look_target.y = global_position.y
	var target_basis = global_transform.looking_at(look_target, Vector3.UP).basis
	global_transform.basis = global_transform.basis.slerp(target_basis, delta * 5.0)

func _perform_attack():
	can_attack = false
	if player and player.has_method("take_damage"):
		player.take_damage(attack_damage)
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _return_to_patrol():
	current_state = State.PATROL
	is_waiting_at_patrol = false
	search_timer = 0.0

	var nearest_index = 0
	var nearest_distance = INF
	for i in range(patrol_points.size()):
		var dist = global_position.distance_to(patrol_points[i])
		if dist < nearest_distance:
			nearest_distance = dist
			nearest_index = i

	current_patrol_index = nearest_index
	nav_agent.target_position = patrol_points[current_patrol_index]

func _on_vision_entered(body):
	if body == player:
		current_state = State.CHASE
		search_timer = 0.0

func _on_vision_exited(body):
	if body == player and (current_state == State.CHASE or current_state == State.ATTACK):
		current_state = State.SEARCH
		search_timer = 0.0
		search_target = global_position + last_player_direction * search_distance
		search_target.y = global_position.y
		nav_agent.target_position = search_target

func _on_attack_entered(body):
	if body == player and current_state == State.CHASE:
		current_state = State.ATTACK

func _on_attack_exited(body):
	if body == player and current_state == State.ATTACK:
		current_state = State.CHASE

func take_damage(amount: float):
	if is_dead:
		return
	health -= amount
	if health <= 0:
		die()

func die():
	is_dead = true

	if mesh:
		var material = mesh.get_surface_override_material(0)
		if material:
			material.albedo_color = Color(0.3, 0.3, 0.3)

	collision_layer = 0
	collision_mask = 0

	await get_tree().create_timer(2.0).timeout
	queue_free()
