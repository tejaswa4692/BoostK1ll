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
