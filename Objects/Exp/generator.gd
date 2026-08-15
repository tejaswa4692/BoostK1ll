extends StaticBody3D

var max_pow_output = 500
@onready var location_to_connect_wire_to: Marker3D = $location_to_connect_wire_to
var connected = false
@onready var generator_humm: AudioStreamPlayer3D = $GeneratorHumm
@onready var layer_2_sound: AudioStreamPlayer3D = $Layer2Sound

func _ready() -> void:
	generator_humm.play()
