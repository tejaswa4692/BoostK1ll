extends StaticBody3D

@onready var base: MeshInstance3D = $Base
@onready var antenna: MeshInstance3D = $Base/Antenna
@onready var timer: Timer = $Timer
@onready var transmission_info: RichTextLabel = $YagiUI/TransmissionInfo
@onready var point: Button = $YagiUI/Point
@onready var scan_everywhere: Button = $YagiUI/ScanEverywhere
@onready var x: LineEdit = $YagiUI/VBoxContainer/X
@onready var y: LineEdit = $YagiUI/VBoxContainer/Y
@onready var z: LineEdit = $YagiUI/VBoxContainer/Z
@onready var scam_area: Area3D = $Base/Antenna/ScamArea

var nearestrssi: Node3D = null

var scanning: bool = false
var scan_elapsed: float = 0.0
var scan_duration: float = 5.0
var scan_yaw_speed: float = 2.0   # full rotations over the scan
var scan_pitch_speed: float = 5.0 # pitch oscillations over the scan
var scan_pitch_range_deg: float = 60.0
var scan_alignment_threshold: float = 0.85 # how "on target" the antenna must be, 0-1

var best_target: Node3D = null
var best_distance: float = INF


func _ready() -> void:
	scan_everywhere.pressed.connect(_on_scan_everywhere_pressed)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		var player: Node3D = get_tree().get_first_node_in_group("player")
		point_yagi_to(player.global_position)


func _process(delta: float) -> void:
	if not scanning:
		return

	scan_elapsed += delta
	var t: float = scan_elapsed / scan_duration

	base.rotation.y = t * TAU * scan_yaw_speed
	antenna.rotation.x = sin(t * TAU * scan_pitch_speed) * deg_to_rad(scan_pitch_range_deg)

	_sample_scan()

	if scan_elapsed >= scan_duration:
		_finish_scan()


func _on_scan_everywhere_pressed() -> void:
	if scanning:
		return
	scanning = true
	scan_elapsed = 0.0
	best_target = null
	best_distance = INF
	transmission_info.text = "Scanning..."


func _sample_scan() -> void:
	var forward: Vector3 = -antenna.global_transform.basis.z
	var bodies: Array[Node3D] = []
	for body in scam_area.get_overlapping_bodies():
		bodies.append(body)

	for body: Node3D in bodies:
		if body == self:
			continue

		var to_target: Vector3 = body.global_position - antenna.global_position
		var distance: float = to_target.length()
		if distance <= 0.0:
			continue

		var alignment: float = forward.normalized().dot(to_target.normalized())
		if alignment < scan_alignment_threshold:
			continue

		if distance < best_distance:
			best_distance = distance
			best_target = body


func _finish_scan() -> void:
	scanning = false
	nearestrssi = best_target

	if best_target:
		transmission_info.text = "Locked onto: " + best_target.name
		point_yagi_to(best_target.global_position)
	else:
		transmission_info.text = "No signal found"


func point_yagi_to(target_pos: Vector3) -> void:
	var local_target: Vector3 = base.get_parent().to_local(target_pos) - base.position
	base.rotation.y = atan2(local_target.x, local_target.z)
	antenna.rotation.x = -atan2(local_target.y, Vector2(local_target.x, local_target.z).length()) + deg_to_rad(90)
