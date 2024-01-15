extends Node3D

var player_raycast_3d:Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_raycast_3d = $player/camera/RayCast3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
