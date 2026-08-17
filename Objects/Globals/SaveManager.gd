extends Node

const SAVE_PATH: String = "user://savegame.json"

var _saveable_nodes: Array = []
var _placed_nodes: Array = []


func register_saveable(node: Node) -> void:
	if not _saveable_nodes.has(node):
		_saveable_nodes.append(node)
		print("Registered saveable: ", node.get_path())


func unregister_saveable(node: Node) -> void:
	_saveable_nodes.erase(node)


func register_placed(node: Node) -> void:
	if not _placed_nodes.has(node):
		_placed_nodes.append(node)
		print("Registered placed: ", node.get_path())


func unregister_placed(node: Node) -> void:
	_placed_nodes.erase(node)


func save_game() -> void:
	print("save_game called, saveable count: ", _saveable_nodes.size(), " placed count: ", _placed_nodes.size())

	var save_data: Dictionary = {"nodes": {}, "placed_objects": []}

	for node in _saveable_nodes:
		if not is_instance_valid(node):
			continue
		if node.has_method("get_save_data"):
			save_data["nodes"][str(node.get_path())] = node.get_save_data()

	for obj in _placed_nodes:
		if not is_instance_valid(obj):
			continue
		if obj.has_method("get_save_data"):
			save_data["placed_objects"].append({
				"path": str(obj.get_path()),
				"scene_path": obj.scene_file_path,
				"data": obj.get_save_data()
			})

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var text: String = file.get_as_text()
	file.close()

	var save_data: Dictionary = JSON.parse_string(text)

	# Pass 1: nodes already in the scene tree
	for node in _saveable_nodes:
		if not is_instance_valid(node):
			continue
		var path: String = str(node.get_path())
		if save_data["nodes"].has(path) and node.has_method("load_save_data"):
			node.load_save_data(save_data["nodes"][path])

	# Pass 2: spawn placed objects and load their basic data
	var spawned_placed: Array = []
	for entry in save_data["placed_objects"]:
		var scene: PackedScene = load(entry["scene_path"])
		if scene == null:
			push_warning("SaveManager: could not load scene " + str(entry["scene_path"]))
			continue
		var instance: Node = scene.instantiate()
		get_tree().current_scene.add_child(instance)
		if instance.has_method("load_save_data"):
			instance.load_save_data(entry["data"])
		spawned_placed.append({"node": instance, "data": entry["data"]})

	# Pass 3: reconciliation
	for entry in spawned_placed:
		var node: Node = entry["node"]
		if node.has_method("reconnect_wires"):
			node.reconnect_wires(entry["data"])

	for node in _saveable_nodes:
		if not is_instance_valid(node):
			continue
		var path: String = str(node.get_path())
		if save_data["nodes"].has(path) and node.has_method("reconnect_wires"):
			node.reconnect_wires(save_data["nodes"][path])


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
