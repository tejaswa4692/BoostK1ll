extends CharacterBody3D

@export var move_speed: float = 2.5
@export var jump_velocity: float = 5.0
@export var mouse_sensitivity: float = 0.003
@export var interact_distance: float = 3.0
@export var gravity_align_speed: float = 5.0

@export_group("Water Walk Audio")
@export var water_walk_volume_db: float = 0.0
@export var water_walk_move_threshold: float = 0.3
@onready var walk_cast: RayCast3D = $WalkCast

@onready var fp_camera = $Head/Camera3D
@onready var raycast = $HeadCast
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var satellite_ui: Control = $SatteliteUI
@onready var satellite_item_list: ItemList = $SatteliteUI/ItemList
@onready var movement_controller = $MovementManager
@onready var mount_controller = $MountController
@onready var satellite_ui_controller = $SatelliteUIController
@onready var placement_controller = $PlacementController
@onready var backpack_controller = $BackPackController
@onready var breakercast = $Head/Camera3D/ScrapBreaker
@onready var water_walk: AudioStreamPlayer3D = $WaterWalk
@onready var scraps_warning: RichTextLabel = $NeedScraps
@onready var build_menu: Control = $InventoryUI/BuildMenu


var ui_open: bool
var settings_open: bool = false
var is_mounted: bool = false
var mounted_target = null
var mount_source = null
var nearest_rocket = null
var nearest_backpack: Backpack = null
var open_backpack: Backpack = null
var pitch: float = 0.0
var scraps: int = 0:
	set(value):
		scraps = value
		$NormalBoneyUI/Scrapcounter.text = "Scraps: " + str(scraps)
var refinedscraps: int = 0:
	set(value):
		refinedscraps = value
		$"NormalBoneyUI/Refined Scrap".text = "Refined Scraps: " + str(refinedscraps)
var copper: int = 0:
	set(value):
		copper = value
		$NormalBoneyUI/Copper.text = "Copper: " + str(copper)
var iron: int = 0:
	set(value):
		iron = value
		$NormalBoneyUI/Iron.text = "Iron: " + str(iron)

var water_walk_active: bool = false


func _ready() -> void:
	scraps = 1000
	refinedscraps = 1000
	copper = 1000
	iron = 1000
	scraps_warning.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.current = true
	water_walk.volume_db = water_walk_volume_db


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not is_mounted and !settings_open and !ui_open:
		rotate(up_direction, -event.relative.x * mouse_sensitivity)
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, deg_to_rad(-89), deg_to_rad(89))
		head.rotation.x = pitch

	if event is InputEventMouseButton and event.pressed and not is_mounted and !settings_open and !ui_open:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			InventoryGlobal.select_next()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			InventoryGlobal.select_prev()

	if event.is_action_pressed("interact") and not event.is_echo() and not Input.is_key_pressed(KEY_SHIFT):
		handle_interact()
	
	
	if Input.is_action_just_pressed("ui_cancel") and ui_open:
		satellite_ui.visible = false
		if open_backpack != null:
			backpack_controller.close_backpack()

func _physics_process(delta: float) -> void:
	if is_mounted:
		return
		
	movement_controller.update_gravity(delta)
	movement_controller.handle_movement(delta, head)
	movement_controller.update_tree(animation_tree)
	update_water_walk_audio()
	
	if Input.is_action_just_pressed("buildmenu") and !settings_open and (!ui_open or build_menu.visible):
		build_menu.showorhide_build_menu()
		
	if Input.is_action_just_pressed("Place") and !ui_open and !settings_open:
		handle_scrap_breaking()
		
	$Help.visible = GraphicsSettings.showkeybinds


func handle_interact() -> void:
	if open_backpack != null:
		backpack_controller.close_backpack()
	elif is_mounted:
		if mounted_target and !mounted_target.can_unmount():
			return
		mount_controller.unmount()
	elif nearest_rocket != null:
		mount_controller.mount(nearest_rocket)
	elif nearest_backpack != null:
		backpack_controller.open_backpack(nearest_backpack)


func set_nearest_rocket(rocket) -> void:
	nearest_rocket = rocket


func set_nearest_backpack(bp: Backpack) -> void:
	nearest_backpack = bp


func handle_scrap_breaking() -> bool:
	if not breakercast.is_colliding():
		return false

	var scrap_scene = breakercast.get_collider()
	if not scrap_scene.is_in_group("scrap"):
		return false

	scraps += scrap_scene.scrap_quantity
	scrap_scene.remove()
	return true


func update_water_walk_audio() -> void:
	if is_mounted:
		stop_water_walk_audio()
		return
	var planet = movement_controller.current_planet
	var is_moving: bool = velocity.x != 0.0 or velocity.z != 0.0
	var should_play: bool = walk_cast.is_colliding() and is_moving and planet != null and planet.has_water
	if should_play and not water_walk.playing:
		water_walk.volume_db = water_walk_volume_db
		water_walk.play()
	elif not should_play and water_walk.playing:
		water_walk.stop()

func stop_water_walk_audio() -> void:
	water_walk.stop()


func get_resource_amount(resource_name: String) -> int:
	match resource_name:
		"scraps":
			return scraps
		"refinedscraps":
			return refinedscraps
		"copper":
			return copper
		"iron":
			return iron
		_:
			return 0

func add_resource_amount(resource_name: String, amount: int) -> void:
	match resource_name:
		"scraps":
			scraps += amount
		"refinedscraps":
			refinedscraps += amount
		"copper":
			copper += amount
		"iron":
			iron += amount
