extends Node
@onready var rocket: RigidBody3D = get_parent()

var satellite_scene = preload("res://Objects/sattelite.tscn")
var satellite: RigidBody3D

func setup_sattelite(sat_name = "Explorer I") -> void:
	if satellite != null:
		return
	var sattelite_instance = satellite_scene.instantiate()
	var marker: Marker3D = rocket.UpgradeStageMesh[rocket.current_stage].get_node("Marker3D")
	sattelite_instance.position = rocket.to_local(marker.global_position)
	sattelite_instance.freeze = true
	sattelite_instance.satellite_name = sat_name
	rocket.add_child(sattelite_instance)
	satellite = sattelite_instance
	rocket.mass += satellite.mass

func eject_satellite() -> void:
	if satellite == null or !satellite.freeze:
		return
	var world_transform = satellite.global_transform
	rocket.remove_child(satellite)
	rocket.get_parent().add_child(satellite)
	satellite.global_transform = world_transform
	satellite.freeze = false
	satellite.linear_velocity = rocket.linear_velocity
	satellite.angular_velocity = rocket.angular_velocity
	rocket.mass -= satellite.mass
	satellite = null
