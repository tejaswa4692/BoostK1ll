extends Node3D

@export var is_placed: bool = false
@export var handles_save_input: bool = false
@onready var parent = get_parent()

func _ready() -> void:
	if parent == null:
		push_warning("Saveable: no parent found on " + str(get_path()))
		return
	if is_placed:
		SaveManager.register_placed(parent)
	else:
		SaveManager.register_saveable(parent)


func _exit_tree() -> void:
	if parent == null:
		return
	if is_placed:
		SaveManager.unregister_placed(parent)
	else:
		SaveManager.unregister_saveable(parent)


func _input(event: InputEvent) -> void:
	if not handles_save_input:
		return
	if event.is_action_pressed("debug_save"):
		SaveManager.save_game()
		print("Game saved")
	if event.is_action_pressed("debug_load"):
		SaveManager.load_game()
		print("Game loaded")
