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
	var did_place: bool = place_and_handle(item_name, item_data.costs)
	if did_place and item_name == "observatory":
		planet.change_observatory_status()

func place_and_handle(item_name: String, costs: Dictionary) -> bool:
	if not has_enough_resources(costs):
		show_scraps_warning(costs)
		return false
	var instance = Items.items[item_name].scene.instantiate()
	player.get_tree().root.add_child(instance)
	var point = player.raycast.get_collision_point()
	var normal = player.raycast.get_collision_normal()

	var forward: Vector3 = -player.global_basis.z
	forward = forward - forward.project(normal)
	if forward.length_squared() < 0.0001:
		forward = player.global_basis.x - player.global_basis.x.project(normal)
	forward = forward.normalized()

	instance.global_position = point
	instance.global_basis = Basis.looking_at(forward, normal)
	deduct_resources(costs)
	return true

func has_enough_resources(costs: Dictionary) -> bool:
	for resource_name: String in costs:
		if player.get_resource_amount(resource_name) < costs[resource_name]:
			return false
	return true

func deduct_resources(costs: Dictionary) -> void:
	for resource_name: String in costs:
		player.add_resource_amount(resource_name, -costs[resource_name])

func show_scraps_warning(costs: Dictionary) -> void:
	if scraps_warning_tween != null and scraps_warning_tween.is_valid():
		scraps_warning_tween.kill()
	var parts: Array = []
	for resource_name: String in costs:
		parts.append("%d %s" % [costs[resource_name], resource_name])
	player.scraps_warning.text = "need " + ", ".join(parts) + " for this action"
	player.scraps_warning.modulate.a = 1.0
	player.scraps_warning.show()
	scraps_warning_tween = player.scraps_warning.create_tween()
	scraps_warning_tween.tween_interval(0.2)
	scraps_warning_tween.tween_property(player.scraps_warning, "modulate:a", 0.0, 0.2)
	scraps_warning_tween.tween_callback(player.scraps_warning.hide)
