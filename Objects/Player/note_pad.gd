extends Control

@onready var player: CharacterBody3D = get_parent().get_parent()
@onready var item_list: ItemList = $ItemList


func _on_button_pressed() -> void:
	var pos_string: String = "%.1f, %.1f, %.1f" % [player.global_position.x, player.global_position.y, player.global_position.z]
	item_list.add_item(str(pos_string))
