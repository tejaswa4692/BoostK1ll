extends Node3D

var playerin: bool = false
@onready var paper: Control = $Paper

func _ready() -> void:
	paper.hide()
	set_process(false)

func showhidepaper() -> void:
	if Input.is_action_just_pressed("interact"):
		if paper.visible:
			paper.hide()
		else:
			paper.show()

func _process(delta: float) -> void:
	showhidepaper()

func _on_player_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("in")
		playerin = true
		set_process(true)

func _on_player_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		playerin = false
		set_process(false)
