extends StaticBody3D
class_name MudfishHome

@export var min_respawn_delay: float = 1.0
@export var max_respawn_delay: float =  3.2
@export var spawn_radius: float = 3.0
@export var spawn_lift: float = 0.5

var can_spawn: bool = true

var stored_fish: Array = []

@onready var respawn_timer: Timer = $RespawnTimer
@onready var entrance_area: Area3D = $EntranceArea
@export var max_fish_per_respawn: int = 4


func _ready() -> void:
	respawn_timer.timeout.connect(_on_respawn_timer_timeout)
	entrance_area.body_entered.connect(_on_entrance_area_body_entered)
	_queue_next_respawn()

func _on_entrance_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("mudfish"):
		body.try_enter_home(self)

func store_fish(fish: Node3D) -> void:
	stored_fish.append(fish)

func _on_respawn_timer_timeout() -> void:
	if can_spawn:
		var count: int = min(max_fish_per_respawn, stored_fish.size())
		for i in range(count):
			var fish = stored_fish.pop_at(randi() % stored_fish.size())
			var right: Vector3 = global_transform.basis.x
			var forward: Vector3 = -global_transform.basis.z
			var up: Vector3 = global_transform.basis.y
			var offset: Vector3 = right * randf_range(-spawn_radius, spawn_radius) \
				+ forward * randf_range(-spawn_radius, spawn_radius) \
				+ up * spawn_lift
			fish.exit_home(global_position + offset)
	_queue_next_respawn()

func _queue_next_respawn() -> void:
	respawn_timer.wait_time = randf_range(min_respawn_delay, max_respawn_delay)
	respawn_timer.start()


func _on_player_detect_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		can_spawn = false


func _on_player_detect_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		can_spawn = true
