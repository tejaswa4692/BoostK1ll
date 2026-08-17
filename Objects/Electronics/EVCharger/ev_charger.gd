extends StaticBody3D

var connected: bool = false
var has_electricity_running: bool = false
@onready var location_to_connect_wire_to: Marker3D = $location_to_connect_wire_to
var rover_scene = null
var player = null
@onready var ev_charger: Control = $EVCharger
@onready var evui: Control = $EVCharger/EVUI
@onready var electricity_warning: Control = $EVCharger/ElectricityWarning
@onready var no_car_warning: Control = $EVCharger/NoCarWarning

func _ready() -> void:
	ev_charger.hide()



func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and player != null:
		if !player.ui_open and !player.is_mounted and !player.settings_open:
			showhideevUI()
	elif Input.is_action_just_pressed("interact") and ev_charger.visible:
		ev_charger.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func showhideevUI() -> void:
	if ev_charger.visible:
		ev_charger.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		ev_charger.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if has_electricity_running:
			if rover_scene != null:
				evui.show()
				electricity_warning.hide()
				no_car_warning.hide()
			else:
				evui.hide()
				electricity_warning.hide()
				no_car_warning.show()
		else:
			evui.hide()
			electricity_warning.show()
			no_car_warning.hide()

func _on_car_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("vehicle"):
		rover_scene = body

func _on_car_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("vehicle"):
		rover_scene = null

func _on_player_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player = body


func _on_player_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player = null


func _on_ev_timer_timeout() -> void:
	if rover_scene != null:
		rover_scene.charge = rover_scene.max_charge
		rover_scene.canmount = true


func _on_full_charge_pressed() -> void:
	if rover_scene != null:
		$EVTimer.start()
		$Charging.play()
		rover_scene.canmount = false
