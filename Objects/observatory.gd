extends Node3D

var satellite_target = null
var rocket_based :  bool = false
var rocket = null
var rover_scene = preload("res://Assets/Rover/rover.tscn")

func _on_area_3d_body_entered(body):
	if body.has_method("set_nearest_rocket"):
		body.set_nearest_rocket(self)

func _on_area_3d_body_exited(body):
	if body.has_method("set_nearest_rocket"):
		body.set_nearest_rocket(null)
	if body.has_method("hide_satellite_ui"):
		body.hide_satellite_ui()

func get_mount_target():
	return satellite_target

func assign_satellite(sat) -> void:
	if is_instance_valid(satellite_target):
		satellite_target.assigned_observatory = null
	satellite_target = sat
	sat.assigned_observatory = self
#
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("setup_sattelite") and rocket_based:
		rocket.setup_sattelite()

func _on_rocket_rebaser_body_entered(body: Node3D) -> void:
	if body.is_in_group("rocket"):
		rocket_based = true
		rocket = body


func _on_rocket_rebaser_body_exited(body: Node3D) -> void:
	if body.is_in_group("rocket"):
		rocket_based = false
		rocket = null

func dock_satellite_on_rocket(satname: String) -> void:
	if rocket != null:
		rocket.satellite_dock_controller.setup_sattelite(satname)

func pleaserefuel() -> void:
	if rocket != null:
		rocket.flight_controller.fuel = rocket.flight_controller.max_fuel #HERE TO CHANGE FUEL DONT FORGET IT LATER
		rocket.flight_controller.fuel_guage.value = rocket.flight_controller.fuel


func spawn_vehicle_rover() -> void:
	var rover_instance = rover_scene.instantiate()
	rover_instance.position = $Marker3D.position
	rover_instance.rotation = $Marker3D.rotation
	add_child(rover_instance)


### Save logic

func get_save_data() -> Dictionary:
	return {
		"position": {"x": global_position.x, "y": global_position.y, "z": global_position.z},
		"basis": {
			"x": {"x": global_transform.basis.x.x, "y": global_transform.basis.x.y, "z": global_transform.basis.x.z},
			"y": {"x": global_transform.basis.y.x, "y": global_transform.basis.y.y, "z": global_transform.basis.y.z},
			"z": {"x": global_transform.basis.z.x, "y": global_transform.basis.z.y, "z": global_transform.basis.z.z}
		},
		"satellite_target_path": str(satellite_target.get_path()) if is_instance_valid(satellite_target) else ""
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

	var sat_path: String = data.get("satellite_target_path", "")
	if sat_path != "":
		var sat: Node = get_node_or_null(sat_path)
		if sat:
			assign_satellite(sat)
