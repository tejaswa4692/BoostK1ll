extends RigidBody3D

var canmove: bool = true
var canmount: bool = true
var has_player: bool = false
var current_player: CharacterBody3D = null

@onready var flight_controller = $FlightController
@onready var landing_gear_controller = $LandingGearController
@onready var satellite_dock_controller = $SatelliteDockController
@onready var damage_controller = $DamageController
@onready var help_ui_controller = $HelpUIController
@onready var show_key_tip: RichTextLabel = $ShowKeyTip
@onready var upgrade_clouds: Node3D = $UpgradeClouds


@onready var UpgradeStageMesh: Array = [$Rocket, $"Rocket(Stage1)", $"Rocket(Stage2)"] 

@export var current_stage: int = 0:
	set(value):
		var previous_stage: int = current_stage
		current_stage = value
		show_correct_stage(value, previous_stage)

func _ready() -> void:
	show_key_tip.hide()
	show_correct_stage(current_stage, -1) #-1 cuz dont know
	CameraManager.register(self)
	linear_damp = 0
	gravity_scale = 0
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(_on_body_entered)
	$Control/YouDied.hide()
	$Control/Help.hide()
	flight_controller.setup()
	await landing_gear_controller.play_initial_deploy()

func _on_body_entered(body: Node) -> void:
	damage_controller.collision_impact(body)

func _physics_process(_delta: float) -> void:
	if canmove:
		flight_controller.handle_gravity()
		if has_player:
			$Control.show()
			flight_controller.handle_rotation()
			flight_controller.handle_thrust()
			flight_controller.handle_rcs()
			landing_gear_controller.handle_landing_gear()
			flight_controller.update_thrust_visual(_delta)
			if GraphicsSettings.showkeybinds:
				$Help.show()
			else:
				$Help.hide()
		else:
			$Control.hide()
			$Help.hide()
			flight_controller.set_thrust_gradient_bias(0)
	else:
		flight_controller.set_thrust_gradient_bias(0)
		$Control/YouDied.show()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("R") and !canmove:
			CameraManager.reset()
			get_tree().reload_current_scene()
	
	if !has_player:
		return
	
	if event is InputEventKey:
		if Input.is_action_just_pressed("eject"):
			satellite_dock_controller.eject_satellite()
		if Input.is_action_just_pressed("help-open"):
			help_ui_controller.handle_help()
	
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			flight_controller.throttleslider.value += flight_controller.throttleslider.step
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			flight_controller.throttleslider.value -= flight_controller.throttleslider.step

func _on_proximity_entered(body: Node) -> void:
	if body.is_in_group("planet"):
		damage_controller.collision_impact(body)
	if body.has_method("set_nearest_rocket"):
		body.set_nearest_rocket(self)

func _on_proximity_exited(body: Node) -> void:
	if body.has_method("set_nearest_rocket"):
		body.set_nearest_rocket(null)

func can_unmount() -> bool:
	show_key_tip.hide()
	return canmove

func show_correct_stage(number: int, previous_number: int = -1) -> void:
	if UpgradeStageMesh.is_empty():
		return
	for i in UpgradeStageMesh:
		i.hide()
	UpgradeStageMesh[number].show() 
	
	
	if previous_number == -1 or previous_number == number:
		return
	
	var old_anim: AnimationPlayer = UpgradeStageMesh[previous_number].get_node("AnimationPlayer")
	var new_anim: AnimationPlayer = UpgradeStageMesh[number].get_node("AnimationPlayer")
	print(old_anim)
	print(new_anim)
	
	new_anim.play("CubeAction_004") 
	new_anim.seek(old_anim.current_animation_position, true)
	if !old_anim.is_playing():
		new_anim.pause()


func set_player(player: Node3D) -> void:
	current_player = player
	has_player = player != null
