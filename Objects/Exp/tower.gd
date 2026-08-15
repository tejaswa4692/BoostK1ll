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
