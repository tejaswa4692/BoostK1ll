extends Node
class_name MudfishBrain

enum State { IDLE, WANDER, GRAZE, FLEE, GO_HOME }

@export var ray_height: float = 5.0
@export var ray_length: float = 10.0
@export var turn_speed: float = 5.0
@export var align_threshold_deg: float = 3.0

@export_group("State Weights")
@export var idle_weight: float = 0.3
@export var wander_weight: float = 0.4
@export var graze_weight: float = 0.3

@export_group("Flee")
@export var flee_distance: float = 8.0
@export var flee_speed_multiplier: float = 1.8
@export var flee_safe_duration: float = 1.5

var flee_cooldown: float = 0.0

@export_group("Home")
@export var go_home_weight: float = 0.2
var seeking_home: bool = false
var home: Node3D = null
var entered_home: bool = false

var state: State = State.IDLE
var target_position: Vector3 = Vector3.ZERO
var idle_target_dir: Vector3 = Vector3.ZERO
var threat: Node3D = null
var base_move_speed: float = 0.0
var move_blend: float = 0.0

@onready var body: CharacterBody3D = get_parent()
@onready var surface_aligner: SurfaceAligner = body.get_node("SurfaceAligner")
@onready var walkable_area: Area3D = body.get_node("WalkableArea")
@onready var walkable_shape: CollisionShape3D = body.get_node("WalkableArea/CollisionShape3D")
@onready var ray_cast_3d: RayCast3D = body.get_node("RayCast3D")
@onready var timer: Timer = body.get_node("Timer")

func _ready() -> void:
	base_move_speed = surface_aligner.move_speed
	timer.timeout.connect(_on_timer_timeout)

func update(delta: float) -> void:
	if threat != null:
		state = State.FLEE

	match state:
		State.WANDER:
			process_wander(delta)
		State.IDLE:
			process_idle_turn(delta)
		State.GRAZE:
			surface_aligner.apply_gravity(delta)
			move_blend = 0.0
		State.FLEE:
			process_flee(delta)
		State.GO_HOME:
			process_go_home(delta)

func process_go_home(delta: float) -> void:
	if home == null:
		state = State.IDLE
		seeking_home = false
		return
	seeking_home = true
	face_direction(home.global_position - body.global_position, delta)
	surface_aligner.move_to(home.global_position, delta)
	move_blend = 1.0

func reset_after_home() -> void:
	state = State.IDLE
	seeking_home = false

func set_home(h: Node3D) -> void:
	home = h

func clear_home() -> void:
	home = null

func process_wander(delta: float) -> void:
	seeking_home = false
	face_direction(target_position - body.global_position, delta)
	var arrived: bool = surface_aligner.move_to(target_position, delta)
	move_blend = 0.0 if arrived else 1.0
	if arrived:
		state = State.IDLE

func process_idle_turn(delta: float) -> void:
	seeking_home = false
	surface_aligner.apply_gravity(delta)
	var aligned: bool = face_direction(idle_target_dir, delta)
	move_blend = 0.0
	if aligned:
		idle_target_dir = Vector3.ZERO

func process_flee(delta: float) -> void:
	surface_aligner.move_speed = base_move_speed * flee_speed_multiplier

	if home != null:
		seeking_home = true
		face_direction(home.global_position - body.global_position, delta)
		surface_aligner.move_to(home.global_position, delta)
		move_blend = 1.0
		return

	seeking_home = false
	var away_source: Node3D = threat if threat != null else null
	var flee_point: Vector3
	if away_source != null:
		var away: Vector3 = body.global_position - away_source.global_position
		if away.length() < 0.01:
			away = -body.global_transform.basis.z
		flee_point = body.global_position + away.normalized() * flee_distance
	else:
		flee_point = body.global_position - body.global_transform.basis.z * flee_distance

	face_direction(flee_point - body.global_position, delta)
	surface_aligner.move_to(flee_point, delta)
	move_blend = 1.0

func face_direction(direction: Vector3, delta: float) -> bool:
	var up: Vector3 = body.global_transform.basis.y.normalized()
	var flat_dir: Vector3 = direction - up * direction.dot(up)
	if flat_dir.length() < 0.01:
		return true
	flat_dir = flat_dir.normalized()

	var raw_forward: Vector3 = -body.global_transform.basis.z
	var flat_forward: Vector3 = (raw_forward - up * raw_forward.dot(up)).normalized()

	var angle: float = flat_forward.signed_angle_to(flat_dir, up)
	var smooth: float = angle * min(turn_speed * delta, 1.0)
	body.global_rotate(up, smooth)

	return abs(angle) <= deg_to_rad(align_threshold_deg)
	return abs(angle) <= deg_to_rad(align_threshold_deg)

func set_threat(t: Node3D) -> void:
	threat = t

func clear_threat() -> void:
	threat = null


func _on_timer_timeout() -> void:
	if state == State.WANDER or state == State.FLEE:
		return
	choose_next_state()

func choose_next_state() -> void:
	var total: float = idle_weight + wander_weight + graze_weight
	if home != null:
		total += go_home_weight
	var roll: float = randf() * total
	if roll < idle_weight:
		start_idle_turn()
	elif roll < idle_weight + wander_weight:
		pick_random_target()
	elif roll < idle_weight + wander_weight + graze_weight:
		state = State.GRAZE
	else:
		state = State.GO_HOME


func start_idle_turn() -> void:
	var up: Vector3 = body.global_transform.basis.y
	var current_forward: Vector3 = -body.global_transform.basis.z
	var random_angle: float = randf_range(-PI, PI)
	idle_target_dir = current_forward.rotated(up, random_angle)
	state = State.IDLE

func pick_random_target() -> void:
	var extents: Vector3 = walkable_shape.shape.get_debug_mesh().get_aabb().size / 2.0
	var random_local: Vector3 = Vector3(
		randf_range(-extents.x, extents.x),
		0.0,
		randf_range(-extents.z, extents.z)
	)
	var candidate: Vector3 = walkable_area.global_position + random_local
	var origin: Vector3 = candidate - surface_aligner.gravity_direction * ray_height
	var direction: Vector3 = surface_aligner.gravity_direction
	ray_cast_3d.global_position = origin
	ray_cast_3d.target_position = ray_cast_3d.global_transform.basis.inverse() * (direction * ray_length)
	ray_cast_3d.force_raycast_update()
	if ray_cast_3d.is_colliding() and ray_cast_3d.get_collider().is_in_group("planet"):
		target_position = ray_cast_3d.get_collision_point()
		state = State.WANDER
