extends Node3D
@onready var clouds: GPUParticles3D = $Clouds

func upgradecloudsemit() -> void:
	clouds.emitting = true
