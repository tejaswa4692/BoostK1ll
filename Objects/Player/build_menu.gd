extends Control

@onready var player: CharacterBody3D = get_parent().get_parent()
@onready var item_list: ItemList = $ItemList
@onready var thumbnail: TextureRect = $TextureRect
@onready var textbox: RichTextLabel = $RichTextLabel

func show_information(index: int) -> void:
	var item_name: String = Items.items.keys()[index]
	var item_data: Dictionary = Items.items[item_name]
	textbox.text = item_data.description
	thumbnail.texture = item_data.icon

func _on_item_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	show_information(index)


func show_build_menu() -> void:
	player.ui_open = true
	InventoryGlobal.isUIopen = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	show()

func hide_build_menu() -> void:
	player.ui_open = false
	InventoryGlobal.isUIopen = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hide()

func showorhide_build_menu() -> void:
	if visible:
		hide_build_menu()
	else:
		show_build_menu()

func try_place_buildmenu() -> void:
	var selected_items: Array = item_list.get_selected_items()
	if selected_items.is_empty():
		return
	var item_name: String = Items.items.keys()[selected_items[0]]
	player.placement_controller.try_place(item_name)
