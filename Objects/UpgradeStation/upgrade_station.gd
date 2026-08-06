extends StaticBody3D

var rocket_in: bool = false
var rocket_scene = null
@onready var upgrade_menu: Control = $UpgradeMenu
@onready var image: TextureRect = $UpgradeMenu/Image
@onready var descBlock: RichTextLabel = $UpgradeMenu/Description
@onready var price: Label = $UpgradeMenu/Price

var current_stage_to_buy: int = 0

var description = {
	0: {
		"description": "Ugraded rocket, bigger hull, rear stablizers allow faster turn during flight along pitch and yaw and a larger fuel tank",
		"cost": {
			"scraps": 200,
			"refined_scraps": 0,
			"copper": 0,
			"iron": 0
		},
		"image": "res://Assets/upgradeimages/Stage1Image.png"
	},
	1: {
		"description": "Even larger rocket body, added canards for more snappy movement, largest fuel tank size, even powerful MK2 thrusters made for both endurance and raw strength",
		"cost": {
			"scraps": 500,
			"refined_scraps": 0,
			"copper": 0,
			"iron": 0
		},
		"image": "res://Assets/upgradeimages/Stage2Image.png"
	}
}

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("dock") and rocket_in:
			openclosemenu()

func buy() -> void:
	if current_stage_to_buy >= description.size():
		print("No more upgrades available")
		return
	if rocket_scene == null or rocket_scene.current_player == null:
		return
	
	var player: CharacterBody3D = rocket_scene.current_player
	var cost: Dictionary = description[current_stage_to_buy]["cost"]
	
	# check affordability first
	for resource_name in cost:
		var amount_needed: int = cost[resource_name]
		match resource_name:
			"scraps":
				if player.scraps < amount_needed:
					print("Not enough ", resource_name)
					return
			"refined_scraps":
				if player.refinedscraps < amount_needed:
					print("Not enough ", resource_name)
					return
			"copper":
				if player.copper < amount_needed:
					print("Not enough ", resource_name)
					return
			"iron":
				if player.iron < amount_needed:
					print("Not enough ", resource_name)
					return
	
	# deduct
	for resource_name in cost:
		var amount_needed: int = cost[resource_name]
		match resource_name:
			"scraps":
				player.scraps -= amount_needed
			"refined_scraps":
				player.refinedscraps -= amount_needed
			"copper":
				player.copper -= amount_needed
			"iron":
				player.iron -= amount_needed
	
	rocket_scene.current_stage += 1
	rocket_scene.flight_controller.fuel += 2500
	rocket_scene.flight_controller.max_fuel += 2500
	rocket_scene.flight_controller.fuel_guage.max_value = rocket_scene.flight_controller.max_fuel
	rocket_scene.flight_controller.fuel_guage.value = rocket_scene.flight_controller.fuel
	current_stage_to_buy += 1
	updateDetails()

func updateDetails() -> void:
	if current_stage_to_buy >= description.size():
		descBlock.text = "Max upgrade reached"
		price.text = ""
		image.texture = null
		return
	descBlock.text = description[current_stage_to_buy]["description"]
	var cost: Dictionary = description[current_stage_to_buy]["cost"]
	price.text = ""
	for resource_name in cost:
		var amount_needed: int = cost[resource_name]
		price.text += resource_name + "->" + str(amount_needed) + "\n"
	image.texture = load(description[current_stage_to_buy]["image"])

func openclosemenu() -> void:
	if upgrade_menu.visible:
		upgrade_menu.hide()
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		upgrade_menu.show()
		updateDetails()
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("rocket"):
		rocket_in = true
		rocket_scene = body

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("rocket"):
		rocket_in = false
		rocket_scene = null


func _on_buy_pressed() -> void:
	buy()
	openclosemenu()
