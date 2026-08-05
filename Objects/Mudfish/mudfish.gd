extends CharacterBody3D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var surface_aligner: SurfaceAligner = $SurfaceAligner
@onready var brain: MudfishBrain = $MudfishBrain
@onready var look_for_home: Area3D = $LookForHome
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var nearest_home = null


func _ready() -> void:
	animation_tree["parameters/MoveParam/blend_amount"] = 0.0

func _physics_process(delta: float) -> void:
	surface_aligner.update_alignment(delta)
	brain.update(delta)
	animation_tree["parameters/MoveParam/blend_amount"] = brain.move_blend

func try_enter_home(home: Node3D) -> bool:
	if not brain.seeking_home:
		return false
	home.store_fish(self)
	visible = false
	collision_shape.set_deferred("disabled", true)
	set_physics_process(false)
	brain.reset_after_home()
	return true

func enter_home() -> void:
	if nearest_home == null:
		brain.reset_after_home()
		return
	nearest_home.store_fish(self)
	visible = false
	collision_shape.set_deferred("disabled", true)
	set_physics_process(false)

func exit_home(spawn_position: Vector3) -> void:
	global_position = spawn_position
	visible = true
	collision_shape.set_deferred("disabled", false)
	set_physics_process(true)
	brain.reset_after_home()

func set_threat(t: Node3D) -> void:
	brain.set_threat(t)
func clear_threat() -> void:
	brain.clear_threat()

func _on_walkable_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		set_threat(body)
func _on_walkable_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		clear_threat()

func _on_look_for_home_body_entered(body: Node3D) -> void:
	if body.is_in_group("mudfishhome"):
		nearest_home = body
		brain.set_home(body)
func _on_look_for_home_body_exited(body: Node3D) -> void:
	if body.is_in_group("mudfishhome"):
		nearest_home = null
		brain.clear_home()
