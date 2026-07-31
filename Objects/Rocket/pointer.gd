extends Node3D

@export var position_to_look: Vector3 = Vector3(0, 0, 0)
@export var min_scale: float = 2.5
@export var max_scale: float = 4.5
@export var max_distance: float = 100.0
@onready var target_position: Control = $Target_Position
@onready var rocket = get_parent()
@onready var xloc: LineEdit = $Target_Position/HBoxContainer/X/Xloc
@onready var yloc: LineEdit = $Target_Position/HBoxContainer/Y/Yloc
@onready var zloc: LineEdit = $Target_Position/HBoxContainer/Z/Zloc
@onready var arrow: MeshInstance3D = $Arrow

func _process(delta: float) -> void:
	safe_look_at(position_to_look)
	update_arrow_scale()

func safe_look_at(target: Vector3) -> void:
	var direction: Vector3 = (target - global_position).normalized()
	if direction.length_squared() < 0.0001:
		return
	var up: Vector3 = Vector3(0, -1, 0)
	if abs(direction.dot(up)) > 0.999:
		up = Vector3(0, 0, 1)
	look_at(target, up)

func update_arrow_scale() -> void:
	var distance: float = global_position.distance_to(position_to_look)
	var t: float = clamp(distance / max_distance, 0.0, 1.0)
	var scale_amount: float = lerp(max_scale, min_scale, t)
	arrow.scale = Vector3.ONE * scale_amount

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("Open_Traget_menu") and rocket.has_player:
			showorhide_menu()

func showorhide_menu():
	if target_position.visible:
		target_position.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		target_position.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_button_pressed() -> void:
	if not (xloc.text.is_valid_float() and yloc.text.is_valid_float() and zloc.text.is_valid_float()):
		return
	var newlookvec: Vector3 = Vector3()
	newlookvec.x = float(xloc.text)
	newlookvec.y = float(yloc.text)
	newlookvec.z = float(zloc.text)
	position_to_look = newlookvec
	showorhide_menu()
