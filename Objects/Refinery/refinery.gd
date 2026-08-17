extends Node3D

var player = null
var has_player: bool = false
var amount_prepared: int = 0
@onready var refinery_ui: Control = $RefineryUI
@onready var key_tip: Sprite3D = $KeyTip

func _ready() -> void:
	key_tip.hide()
	refinery_ui.hide()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and has_player: 
		showhideUI()

func showhideUI() -> void:
	if refinery_ui.visible:
		refinery_ui.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		refinery_ui.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		key_tip.show()
		has_player = true
		player = body


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		key_tip.hide()
		has_player = false
		player = null
		refinery_ui.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

### SAVE LOGIC

func get_save_data() -> Dictionary:
	return {
		"position": {"x": global_position.x, "y": global_position.y, "z": global_position.z},
		"basis": {
			"x": {"x": global_transform.basis.x.x, "y": global_transform.basis.x.y, "z": global_transform.basis.x.z},
			"y": {"x": global_transform.basis.y.x, "y": global_transform.basis.y.y, "z": global_transform.basis.y.z},
			"z": {"x": global_transform.basis.z.x, "y": global_transform.basis.z.y, "z": global_transform.basis.z.z}
		},
		"amount_prepared": amount_prepared
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

	amount_prepared = data["amount_prepared"]
