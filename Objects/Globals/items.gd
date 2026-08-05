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
		"icon": preload("res://icon.svg"),
		"description": "A station that can be used for scrap refinery",
		"costs": {"iron": 10, "copper": 2},
	},
}

func get_item(item_name: String) -> Dictionary:
	return items.get(item_name, {})

func is_placeable(item_name: String) -> bool:
	return items.has(item_name)
