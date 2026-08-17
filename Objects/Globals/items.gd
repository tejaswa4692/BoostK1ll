extends Node

var items: Dictionary = {
	"observatory": {
		"scene": preload("res://Objects/observatory.tscn"),
		"icon": preload("res://Assets/InventoryIcons/observatory.png"),
		"description": "A ground station thats used to control sattelites, refuel rockets, a simple storage chest too, one of the most important buildings in the game, would recommend to place first to get home on a new planet, keep in mind only 1 per planet",
		"costs": {"scraps": 10}
	},
	"rover": {
		"scene": preload("res://Assets/Rover/rover.tscn"),
		"icon": preload("res://Assets/InventoryIcons/rover.png"),
		"description": "A rover that can be used as transport to roam and explore the planet to farm for resources or even look for secrets",
		"costs": {"scraps": 20}
	},
	"ToolStation": {
		"scene": preload("res://Objects/Refinery/refinery.tscn"),
		"icon": preload("res://Assets/InventoryIcons/Furnace.png"),
		"description": "A station that can be used for scrap refinery",
		"costs": {"scraps": 20},
	},
	"UpgradeStation": {
		"scene": preload("res://Objects/UpgradeStation/upgrade_station.tscn"),
		"icon": preload("res://Assets/InventoryIcons/RocketUpgradeStation.png"),
		"description": "An upgrade station to buy rocket upgrades, quiet handy ngl",
		"costs": {"iron": 5, "copper": 20},
	},
	"Tower": {
		"scene": preload("res://Objects/Exp/tower.tscn"),
		"icon": preload("res://Assets/InventoryIcons/tower.png"),
		"description": "An electric pole",
		"costs": {"scraps": 5},
	},
	"Generator": {
		"scene": preload("res://Objects/Exp/generator.tscn"),
		"icon": preload("res://Assets/InventoryIcons/generator.png"),
		"description": "A 50kW generator",
		"costs": {"scraps": 20},
	},
	"EV Charger": {
		"scene": preload("res://Objects/Electronics/EVCharger/ev_charger.tscn"),
		"icon": preload("res://Assets/InventoryIcons/generator.png"),
		"description": "A station that can fill the juice up for your EV",
		"costs": {"scraps": 20},
	}
}

func get_item(item_name: String) -> Dictionary:
	return items.get(item_name, {})

func is_placeable(item_name: String) -> bool:
	return items.has(item_name)
