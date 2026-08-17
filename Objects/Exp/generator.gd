extends StaticBody3D

var max_pow_output = 500
@onready var location_to_connect_wire_to: Marker3D = $location_to_connect_wire_to
var connected = false
@onready var generator_humm: AudioStreamPlayer3D = $GeneratorHumm
@onready var layer_2_sound: AudioStreamPlayer3D = $Layer2Sound

func _ready() -> void:
	generator_humm.play()

#Save logic

func get_save_data() -> Dictionary:
	return {
		"position": {"x": global_position.x, "y": global_position.y, "z": global_position.z},
		"basis": {
			"x": {"x": global_transform.basis.x.x, "y": global_transform.basis.x.y, "z": global_transform.basis.x.z},
			"y": {"x": global_transform.basis.y.x, "y": global_transform.basis.y.y, "z": global_transform.basis.y.z},
			"z": {"x": global_transform.basis.z.x, "y": global_transform.basis.z.y, "z": global_transform.basis.z.z}
		},
		"connected": connected
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

	connected = data["connected"]
