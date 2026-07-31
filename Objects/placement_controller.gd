extends Node

@onready var player: CharacterBody3D = get_parent()
var scraps_warning_tween: Tween = null

func try_place_selected_item() -> void:
	var item_name: String = InventoryGlobal.get_selected_item()
	try_place(item_name)

func try_place(item_name: String) -> void:
	if not Items.is_placeable(item_name):
		return
	if not player.raycast.is_colliding():
		return
	var collider = player.raycast.get_collider()
	if not collider.is_in_group("planet"):
		return
	var planet = collider.get_parent()
	if item_name == "observatory" and planet.has_observatory:
		return
	var item_data: Dictionary = Items.get_item(item_name)
	place_and_handle(item_name, item_data.cost)
	if item_name == "observatory":
		planet.change_observatory_status()

func place_and_handle(item_name: String, cost: int) -> void:
	if player.scraps >= cost:
		var instance = Items.items[item_name].scene.instantiate()
		player.get_tree().root.add_child(instance)
		var point = player.raycast.get_collision_point()
		var normal = player.raycast.get_collision_normal()
		instance.global_position = point
		instance.global_basis = Basis.looking_at(normal)
		instance.rotate_object_local(Vector3.RIGHT, deg_to_rad(-90))
		player.scraps -= cost
	else:
		show_scraps_warning(cost)

func show_scraps_warning(cost: int) -> void:
	if scraps_warning_tween != null and scraps_warning_tween.is_valid():
		scraps_warning_tween.kill()
	player.scraps_warning.text = "need %d scraps for this action" % cost
	player.scraps_warning.modulate.a = 1.0
	player.scraps_warning.show()
	scraps_warning_tween = player.scraps_warning.create_tween()
	scraps_warning_tween.tween_interval(0.2)
	scraps_warning_tween.tween_property(player.scraps_warning, "modulate:a", 0.0, 0.2)
	scraps_warning_tween.tween_callback(player.scraps_warning.hide)
