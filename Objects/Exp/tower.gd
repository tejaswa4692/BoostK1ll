extends StaticBody3D

var towers_closest = []
@onready var location_to_connect_wire_to: Marker3D = $LocationToConnectWireTo
var has_electricity_running: bool = false
const WIRE_MATERIAL: Material = preload("res://Assets/ElectricPole/electriclines.tres")

func _on_tower_distance_body_entered(body: Node3D) -> void:
	if body.is_in_group("tower"):
		towers_closest.append(body)
		create_lines(body.location_to_connect_wire_to)
		if has_electricity_running:
			body.has_electricity_running = true
			
	elif body.is_in_group("electrical_appliance"):
		if body.connected == false:
			towers_closest.append(body)
			create_lines(body.location_to_connect_wire_to)
			body.connected = true
			if has_electricity_running:
				body.has_electricity_running = true
	elif body.is_in_group("generator"):
		if body.connected == false:
			has_electricity_running = true
			towers_closest.append(body)
			create_lines(body.location_to_connect_wire_to)
			body.connected = true
			for i in towers_closest:
				if i.is_in_group("tower") or i.is_in_group("electrical_appliance"):
					i.has_electricity_running = true
 
func create_lines(OtherTowerMarker3D: Marker3D) -> void:
	var from: Vector3 = location_to_connect_wire_to.global_position
	var to: Vector3 = OtherTowerMarker3D.global_position
	var cylinder: CylinderMesh = CylinderMesh.new()
	cylinder.top_radius = 0.03
	cylinder.bottom_radius = 0.03
	cylinder.radial_segments = 4
	cylinder.height = from.distance_to(to)
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.mesh = cylinder
	mesh_instance.material_override = WIRE_MATERIAL
	get_tree().current_scene.add_child(mesh_instance)
	mesh_instance.global_position = (from + to) / 2.0
	mesh_instance.look_at(to, Vector3.UP)
	mesh_instance.rotate_object_local(Vector3.RIGHT, PI / 2.0)

### SAve logic

func get_save_data() -> Dictionary:
	var tower_paths: Array = []
	for t in towers_closest:
		if is_instance_valid(t):
			tower_paths.append(str(t.get_path()))

	return {
		"position": {"x": global_position.x, "y": global_position.y, "z": global_position.z},
		"basis": {
			"x": {"x": global_transform.basis.x.x, "y": global_transform.basis.x.y, "z": global_transform.basis.x.z},
			"y": {"x": global_transform.basis.y.x, "y": global_transform.basis.y.y, "z": global_transform.basis.y.z},
			"z": {"x": global_transform.basis.z.x, "y": global_transform.basis.z.y, "z": global_transform.basis.z.z}
		},
		"has_electricity_running": has_electricity_running,
		"tower_paths": tower_paths
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

	has_electricity_running = data["has_electricity_running"]
	# Wire reconnection happens in a second pass — see reconnect_wires()


func reconnect_wires(data: Dictionary) -> void:
	towers_closest.clear()
	for path in data.get("tower_paths", []):
		var other: Node = get_node_or_null(path)
		if other and other.has_method("get") and "location_to_connect_wire_to" in other:
			towers_closest.append(other)
			create_lines(other.location_to_connect_wire_to)
