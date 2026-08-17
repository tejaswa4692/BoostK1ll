extends RigidBody3D

@export var rcs_force: float = 10.0
@export var thrust_force: float = 15.0

@onready var thruster = $ThrustCone
@onready var thruster2 = $ThrustCone/ThrustCone
@onready var thruster3 = $ThrustCone/ThrustCone2
@onready var throttleslider = $Control/VSlider
var assigned_observatory: Node = null

@export var fuel = 2000
@export var satellite_name := "Explorer I"

var canmount: bool = true

var has_player: bool = false
var current_player: CharacterBody3D = null

const ACTION_THRUST       = "thrust"
const ACTION_RCS_UP       = "rcs_up"
const ACTION_RCS_DOWN     = "rcs_down"
const ACTION_RCS_LEFT     = "rcs_left"
const ACTION_RCS_RIGHT    = "rcs_right"
const ACTION_RCS_FORWARD  = "rcs_forward"
const ACTION_RCS_BACK     = "rcs_back"

var thruster_material: ShaderMaterial

@export var pitch_torque: float = 1.0
@export var yaw_torque: float = 1.0
@export var roll_torque: float = 1.0
@export var stabilization_strength: float = 2.0

const ACTION_PITCH_UP   = "forward"
const ACTION_PITCH_DOWN = "back"
const ACTION_YAW_LEFT   = "left"
const ACTION_YAW_RIGHT  = "right"
const ACTION_ROLL_LEFT  = "roll_left"
const ACTION_ROLL_RIGHT = "roll_right"

var current_bias: float = 0.0

func _ready():
	SatelliteManager.register(self)
	CameraManager.register(self)
	linear_damp = 0
	angular_damp = 0
	gravity_scale = 0
	# duplicate mesh then material separately and cache it
	thruster.mesh = thruster.mesh.duplicate()
	thruster_material = thruster.get_active_material(0).duplicate()
	thruster.material_override = thruster_material
	thruster2.material_override = thruster_material
	thruster3.material_override = thruster_material
	
	set_thrust_gradient_bias(0)
	


func _input(event: InputEvent) -> void:
	if !has_player:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			throttleslider.value += throttleslider.step
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			throttleslider.value -= throttleslider.step


func _physics_process(delta: float) -> void:
	_handle_gravity()
	if has_player:
		_handle_input(delta)
		$Control.show()
	else:
		$Control.hide()
		set_thrust_gradient_bias(0)

func _handle_gravity() -> void:
	for source in GravityManager.sources:
		var to_source: Vector3 = source.global_position - global_position
		var distance: float = to_source.length()
		if distance < 0.01:
			continue
		var direction: Vector3 = to_source.normalized()
		var strength: float
		if source.use_inverse_square:
			strength = source.gravity_strength * source.mass / (distance * distance)
		else:
			strength = source.gravity_strength
		apply_central_force(direction * strength * mass)

func _handle_input(delta: float) -> void:
	_handle_rcs()
	_handle_thrust()
	_handle_rotation()
	_update_thrust_visual(delta)

func _handle_rcs() -> void:
	var local_force := Vector3.ZERO

	if Input.is_action_pressed(ACTION_RCS_UP):
		local_force.z -= 1.0
	if Input.is_action_pressed(ACTION_RCS_DOWN):
		local_force.z += 1.0
	if Input.is_action_pressed(ACTION_RCS_LEFT):
		local_force.x -= 1.0
	if Input.is_action_pressed(ACTION_RCS_RIGHT):
		local_force.x += 1.0
	if Input.is_action_pressed(ACTION_RCS_FORWARD):
		local_force.y += 1.0
	if Input.is_action_pressed(ACTION_RCS_BACK):
		local_force.y -= 1.0

	if local_force != Vector3.ZERO:
		apply_central_force(global_transform.basis * local_force * rcs_force)

func _handle_thrust() -> void:
	if Input.is_action_pressed(ACTION_THRUST):
		var forward := global_transform.basis.y
		apply_central_force(forward * (thrust_force * throttleslider.value))



func set_thrust_gradient_bias(value: float) -> void:
	if thruster_material == null:
		return
	thruster_material.set_shader_parameter("gradient_bias", value)

func _update_thrust_visual(delta: float) -> void:
	var target = throttleslider.value if Input.is_action_pressed(ACTION_THRUST) else 0.0
	current_bias = lerp(current_bias, target, delta * 5.0)
	set_thrust_gradient_bias(current_bias)


func _handle_rotation() -> void:
	var pitch := 0.0
	var yaw := 0.0
	var roll := 0.0
	
	if !Input.is_key_pressed(KEY_SHIFT):
		if Input.is_action_pressed(ACTION_PITCH_UP):
			pitch -= 1.0
		if Input.is_action_pressed(ACTION_PITCH_DOWN):
			pitch += 1.0
		if Input.is_action_pressed(ACTION_YAW_LEFT):
			roll += 1.0
		if Input.is_action_pressed(ACTION_YAW_RIGHT):
			roll -= 1.0
		if Input.is_action_pressed(ACTION_ROLL_LEFT):
			yaw += 1.0
		if Input.is_action_pressed(ACTION_ROLL_RIGHT):
			yaw -= 1.0
			
	var local_torque := Vector3(
		pitch * pitch_torque,
		yaw * yaw_torque,
		roll * roll_torque
	)
	
	var local_angular_velocity: Vector3 = global_transform.basis.inverse() * angular_velocity
	if pitch == 0.0:
		local_torque.x -= local_angular_velocity.x * stabilization_strength
	if yaw == 0.0:
		local_torque.y -= local_angular_velocity.y * stabilization_strength
	if roll == 0.0:
		local_torque.z -= local_angular_velocity.z * stabilization_strength
		
	apply_torque(global_transform.basis * local_torque)


func can_unmount() -> bool:
	return true



### Save Logic

func get_save_data() -> Dictionary:
	return {
		"position": {"x": global_position.x, "y": global_position.y, "z": global_position.z},
		"basis": {
			"x": {"x": global_transform.basis.x.x, "y": global_transform.basis.x.y, "z": global_transform.basis.x.z},
			"y": {"x": global_transform.basis.y.x, "y": global_transform.basis.y.y, "z": global_transform.basis.y.z},
			"z": {"x": global_transform.basis.z.x, "y": global_transform.basis.z.y, "z": global_transform.basis.z.z}
		},
		"linear_velocity": {"x": linear_velocity.x, "y": linear_velocity.y, "z": linear_velocity.z},
		"angular_velocity": {"x": angular_velocity.x, "y": angular_velocity.y, "z": angular_velocity.z},
		"fuel": fuel,
		"satellite_name": satellite_name,
		"canmount": canmount,
		"assigned_observatory_path": str(assigned_observatory.get_path()) if is_instance_valid(assigned_observatory) else ""
	}


func load_save_data(data: Dictionary) -> void:
	var pos: Dictionary = data["position"]
	global_position = Vector3(pos["x"], pos["y"], pos["z"])

	var b: Dictionary = data["basis"]
	var new_basis: Basis = Basis(
		Vector3(b["x"]["x"], b["x"]["y"], b["x"]["z"]),
		Vector3(b["y"]["x"], b["y"]["y"], b["y"]["z"]),
		Vector3(b["z"]["x"], b["z"]["y"], b["z"]["z"])
	)
	global_transform = Transform3D(new_basis, global_position)

	var lv: Dictionary = data["linear_velocity"]
	linear_velocity = Vector3(lv["x"], lv["y"], lv["z"])

	var av: Dictionary = data["angular_velocity"]
	angular_velocity = Vector3(av["x"], av["y"], av["z"])

	fuel = data["fuel"]
	satellite_name = data["satellite_name"]
	canmount = data["canmount"]

	var obs_path: String = data.get("assigned_observatory_path", "")
	if obs_path != "":
		var obs: Node = get_node_or_null(obs_path)
		if obs and obs.has_method("assign_satellite"):
			obs.assign_satellite(self)
