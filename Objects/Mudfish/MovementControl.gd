extends Node
class_name SurfaceAligner

@onready var body: CharacterBody3D = get_parent()

@export var align_speed: float = 5.0
@export var move_speed: float = 2.5
@export var acceleration: float = 10.0
@export var arrive_threshold: float = 0.2

var gravity_direction: Vector3 = Vector3.DOWN
var gravity_force: Vector3 = Vector3.ZERO
var current_planet: GravitySource = null

func _flatten(v: Vector3) -> Vector3:
	return v - gravity_direction * v.dot(gravity_direction)

func update_alignment(delta: float) -> void:
	var active_sources := GravityManager.get_active_sources(body.global_position)
	if active_sources.is_empty():
		current_planet = null
		gravity_direction = Vector3.DOWN
		gravity_force = Vector3.ZERO
		body.up_direction = Vector3.UP
		return

	var strongest_source = null
	var strongest_dist: float = INF
	for source in active_sources:
		var dist: float = body.global_position.distance_to(source.global_position)
		if dist < strongest_dist:
			strongest_dist = dist
			strongest_source = source

	current_planet = strongest_source
	var target_up: Vector3 = (body.global_position - strongest_source.global_position).normalized()
	gravity_direction = -target_up
	gravity_force = gravity_direction * strongest_source.gravity_strength
	body.up_direction = target_up

	var current_up: Vector3 = body.global_transform.basis.y.normalized()
	if current_up.dot(target_up) < 0.9999:
		var axis: Vector3 = current_up.cross(target_up)
		if axis.length() > 0.001:
			var smooth: float = current_up.angle_to(target_up) * min(align_speed * delta, 1.0)
			body.global_rotate(axis.normalized(), smooth)

func move_to(target_position: Vector3, delta: float) -> bool:
	if body.is_on_floor():
		var floor_normal: Vector3 = body.get_floor_normal()
		var into_floor: float = body.velocity.dot(-floor_normal)
		if into_floor < 0:
			body.velocity += floor_normal * into_floor
	else:
		body.velocity += gravity_force * delta

	var horizontal: Vector3 = _flatten(body.velocity)
	var vertical: Vector3 = body.velocity - horizontal

	var flat_to_target: Vector3 = _flatten(target_position - body.global_position)
	var distance: float = flat_to_target.length()
	var target_velocity: Vector3 = Vector3.ZERO if distance <= arrive_threshold else flat_to_target.normalized() * move_speed

	horizontal = horizontal.move_toward(target_velocity, acceleration * delta)
	body.velocity = horizontal + vertical
	body.move_and_slide()
	return distance <= arrive_threshold

func apply_gravity(delta: float) -> void:
	if body.is_on_floor():
		var floor_normal: Vector3 = body.get_floor_normal()
		var into_floor: float = body.velocity.dot(-floor_normal)
		if into_floor < 0:
			body.velocity += floor_normal * into_floor
	else:
		body.velocity += gravity_force * delta

	var horizontal: Vector3 = _flatten(body.velocity)
	horizontal = horizontal.move_toward(Vector3.ZERO, acceleration * delta)
	body.velocity = horizontal + (body.velocity - horizontal)
	body.move_and_slide()
